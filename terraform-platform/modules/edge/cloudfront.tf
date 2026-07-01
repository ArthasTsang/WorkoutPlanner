data "aws_region" "us_east_1" {
  provider = aws.us_east_1
}

data "aws_cloudfront_cache_policy" "s3_cache_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "alb_cache_disabled" {
  name = "Managed-CachingDisabled"
}

# CloudFront Distribution with ALB and S3 Origins
resource "aws_cloudfront_distribution" "dist" {
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_200"
  default_root_object = "index.html"
  aliases = var.is_alt_domain ? ["${var.alt_domain_name}"] : null

  viewer_certificate {
    cloudfront_default_certificate = var.is_alt_domain ? false : true
    acm_certificate_arn            = var.is_alt_domain ? "${var.domain_cert_arn}" : null
    ssl_support_method             = var.is_alt_domain ? "sni-only" : null
    minimum_protocol_version       = var.is_alt_domain ? "TLSv1.2_2021" : null
  }

  # --- Origin 1: Application Load Balancer ---
  dynamic origin {
    for_each = var.is_cost_saving ? [] : [1]

    content{
      domain_name = var.alb_dns_name
      origin_id   = "ALB-Origin"

      custom_header {
        name  = "X-Env-Stage"
        value = "${var.env}"
      }

      custom_header {
        name  = "X-Origin-Verify"
        value = var.cloudfront_origin_header
      }

      custom_origin_config {
        http_port                = 8092
        https_port               = 443
        origin_protocol_policy   = "http-only"
        origin_ssl_protocols     = ["TLSv1.2"]
      }
    }
  }

  # --- Origin 2: S3 Bucket ---
  origin {
    domain_name              = data.aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = "S3-Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }

  # --- Ordered Cache Behavior (Routes /static/* to S3) ---
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-Origin"
    viewer_protocol_policy = "redirect-to-https"

    # Managed Caching Optimized for S3
    cache_policy_id = data.aws_cloudfront_cache_policy.s3_cache_optimized.id
  }

  # --- Default Cache Behavior (Routes to ALB) ---
  dynamic ordered_cache_behavior {
    for_each = var.is_cost_saving ? [] : [1]

    content {
      path_pattern           = "/api/planner/*"
      allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods         = ["GET", "HEAD"]
      target_origin_id       = "ALB-Origin"
      viewer_protocol_policy = "redirect-to-https"

      # Managed Caching Disabled / Forward all to ALB
      cache_policy_id          = data.aws_cloudfront_cache_policy.alb_cache_disabled.id
      origin_request_policy_id = aws_cloudfront_origin_request_policy.alb_origin_request_policy.id

      function_association {
        event_type   = "viewer-request"
        function_arn = aws_cloudfront_function.modify_api_call.arn
      }

      lambda_function_association {
        event_type   = "origin-request"
        lambda_arn   = aws_lambda_function.jwt_validator.qualified_arn
        include_body = false
      }
    }
  }

  custom_error_response {
    error_code            = 502
    response_code         = 503 
    response_page_path    = "/maintenance/index.html"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 503
    response_code         = 503
    response_page_path    = "/maintenance/index.html"
    error_caching_min_ttl = 10
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

# --- Origin Access Control for S3 Security ---
resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "s3-${var.region}-oac"
  description                       = "Secure S3 access from CloudFront"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# S3 policy to allow CloudFront
resource "aws_s3_bucket_policy" "allow_cloudfront_oac" {
  bucket = data.aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipalReadOnly"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${data.aws_s3_bucket.frontend.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.dist.arn
          }
        }
      }
    ]
  })
}

resource "aws_cloudfront_origin_request_policy" "alb_origin_request_policy" {
  name    = "${var.region}-forward-auth-and-user-id"
  comment = "Forwards token and injected email header to the ALB origin"

  cookies_config {
    cookie_behavior = "none"
  }

  query_strings_config {
    query_string_behavior = "all"
  }

  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["Authorization", "X-User-Id", "x-deployment-test"]
    }
  }
}

# CloudFront Function to rewrite WorkoutPlanner API calls
resource "aws_cloudfront_function" "modify_api_call" {
  name    = "${var.region}-ModifyWorkoutPlannerApiCall"
  runtime = "cloudfront-js-2.0"
  comment = "Managed by Terraform"
  publish = true
  code = <<EOF
  function handler(event) {
    var request = event.request;
    // Removes the first part of the path (e.g., /api/* -> /*)
    request.uri = request.uri.replace(/^\/api\//, "/");
    return request;
  }
  EOF
}

# Lambda@Edge for JWT Validation
resource "aws_iam_role" "lambda_edge_role" {
  name = "${local.name_prefix}-${var.region}-lambda-jwt-validator-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"
          ]
        }
      }
    ]
  })

  permissions_boundary = "arn:aws:iam::${local.account_id}:policy/${var.project}-platform-${var.region}-scope-boundary-policy"
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_edge_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lamda@Edge must be deployed in us-east-1
data "aws_s3_object" "jwt_validation_zip" {
  provider = aws.us_east_1
  bucket = "${local.account_alias}-${var.project}-artifact-${data.aws_region.us_east_1.region}"
  key    = "lambda/jwtValidation-${var.region}.zip"
}

# Lamda@Edge must be deployed in us-east-1
resource "aws_lambda_function" "jwt_validator" {
  provider = aws.us_east_1
  function_name = "${var.project}-${var.region}-cloudfront-jwt-validator"
  role          = aws_iam_role.lambda_edge_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  memory_size   = 128
  timeout       = 3
  # Required for Lambda@Edge versioning
  publish       = true 
  # Keep the validation function when CloudFront distribution is removed
  skip_destroy = true

  s3_bucket = data.aws_s3_object.jwt_validation_zip.bucket
  s3_key    = data.aws_s3_object.jwt_validation_zip.key
  # Automatically triggers a code updates/re-deploy if the file in S3 changes
  source_code_hash = data.aws_s3_object.jwt_validation_zip.etag
}
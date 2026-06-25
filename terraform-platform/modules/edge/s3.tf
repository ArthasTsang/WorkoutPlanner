data "aws_s3_bucket" "frontend" {
  bucket = "twyat-${var.env}-mwp-frontend-${var.region}"
}

# resource "aws_s3_bucket" "frontend" {
#   bucket = "${local.account_alias}-${var.project}-frontend-${var.region}"

#   lifecycle {
#     prevent_destroy = true
#   }
# }

# Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket                  = data.aws_s3_bucket.frontend.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Allow CloudFront to access the bucket
data "aws_iam_policy_document" "cloudfront_s3_policy" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${data.aws_s3_bucket.frontend.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.dist.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = data.aws_s3_bucket.frontend.id
  policy = data.aws_iam_policy_document.cloudfront_s3_policy.json
}
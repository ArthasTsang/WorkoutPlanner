output "cloudfront_distribution" {
    description = "CloudFront distribution"
    value       = aws_cloudfront_distribution.dist
}

output "cloudfront_distribution_domain_name" {
    description = "CloudFront distribution domain name"
    value       = aws_cloudfront_distribution.dist.domain_name
}

output "cloudfront_distribution_validation_function_arn" {
    description = "CloudFront distribution validation function arn"
    value       = aws_lambda_function.jwt_validator.arn
}

output "static_website_bucket" {
    description = "Static website bucket"
    value       = data.aws_s3_bucket.frontend.bucket
}
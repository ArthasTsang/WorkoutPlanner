output "docdb_cluster_identifier" {
  description = "DocumentDB cluster id"
  value       = module.docdb.docdb_cluster_identifier
}

output "docdb_cluster_endpoint" {
  description = "DocumentDB cluster endpoint"
  value       = module.docdb.docdb.endpoint
}

output "docdb_secret" {
  description = "Secret name"
  value       = module.docdb.docdb_secret
}

output "docdb_secret_arn" {
  description = "Secret arn"
  value       = module.docdb.docdb_secret_arn
}

output "secret_rotation_function_arn" {
  description = "Secret rotation function arn"
  value       = module.docdb.secret_rotation_function_arn
}

output "alb_dns_name" {
    description = "ALB DNS name"
    value       = module.app.alb_dns_name[*]
}

output "alb_arn" {
    description = "ALB arn"
    value       = module.app.alb_arn[*]
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.app.ecs_cluster_name
}

output "ec_cluster_id" {
  description = "ECS cluster id"
  value       = module.app.ec_cluster_id
}

output "docdb_client_launch_template" {
  description = "DocumentDB client launch template"
  value       = module.app.docdb_client_launch_template
}

output "cloudfront_distribution_id" {
    description = "CloudFront distribution id"
    value       = module.edge.cloudfront_distribution.id
}

output "cloudfront_distribution_url" {
    description = "CloudFront distribution url"
    value       = "https://${module.edge.cloudfront_distribution_domain_name}"
}

output "cloudfront_distribution_validation_function_arn" {
    description = "CloudFront distribution validation function arn"
    value       = module.edge.cloudfront_distribution_validation_function_arn
}

output "static_website_bucket" {
    description = "Static website bucket"
    value       = module.edge.static_website_bucket
}

output "user_pool_id" {
    description = "The ID of the Cognito User Pool"
    value = module.cognito.user_pool_id
}

output "cognito_authority_url" {
  description = "The Cognito Identity Provider authority URL"
  value       = module.cognito.cognito_authority_url
}

output "user_pool_client_id" {
    description = "The ID of the Cognito User Pool Client"
    value = module.cognito.user_pool_client_id
}

output "dynamic_cognito_oauth_domain_url" {
  value = module.cognito.dynamic_cognito_oauth_domain_url
}

output "cloudwatch_log_account_policy" {
    description = "The ARN of the CloudWatch log account policy"
    value = module.logging.cloudwatch_log_account_policy
}
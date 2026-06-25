output "user_pool_id" {
    description = "The ID of the Cognito User Pool"
    value = aws_cognito_user_pool.pool.id
}

output "user_pool_domain" {
    description = "The domain name of the Cognito User Pool"
    value = aws_cognito_user_pool_domain.main.domain
}

output "cognito_authority_url" {
  description = "The Cognito Identity Provider authority URL"
  value       = "https://${aws_cognito_user_pool.pool.endpoint}"
}

output "user_pool_client_id" {
    description = "The ID of the Cognito User Pool Client"
    value = aws_cognito_user_pool_client.client.id
}

output "dynamic_cognito_oauth_domain_url" {
  value = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${var.region}.amazoncognito.com"
}
data "aws_secretsmanager_secret_version" "google_creds" {
  secret_id = "/${var.project}/google_oauth_keys"
}

locals {
  google_keys = jsondecode(data.aws_secretsmanager_secret_version.google_creds.secret_string)
}

# User Pool
resource "aws_cognito_user_pool" "pool" {
  name = "${local.name_prefix}-user-pool"
  alias_attributes         = ["email"]
  auto_verified_attributes = ["email"]

  tags = {
    Name = "${local.name_prefix}-user-pool"
  }

  lifecycle {
    ignore_changes = [
      schema
    ]
  }
}

# User Pool Domain
resource "aws_cognito_user_pool_domain" "main" {
  domain       = var.is_alt_domain ? var.cognito_domain_name : "${local.name_prefix}"
  user_pool_id = aws_cognito_user_pool.pool.id
  certificate_arn = var.is_alt_domain ? var.cognito_domain_cert_arn : null
}

# Google Identity Provider
resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = aws_cognito_user_pool.pool.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    client_id     = local.google_keys["client_id"]
    client_secret = local.google_keys["client_secret"]
    # authorize_scopes = "profile email openid"
    authorize_scopes = "email"
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
    # name     = "name"
  }

  lifecycle {
    ignore_changes = [
      provider_details["attributes_url"],
      provider_details["attributes_url_add_attributes"],
      provider_details["authorize_url"],
      provider_details["oidc_issuer"],
      provider_details["token_request_method"],
      provider_details["token_url"]
    ]
  }
}

# App Client
resource "aws_cognito_user_pool_client" "client" {
  name         = "${local.name_prefix}-app-client"
  user_pool_id = aws_cognito_user_pool.pool.id

  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_flows_user_pool_client = true
  # allowed_oauth_scopes                 = ["email", "openid", "profile"]
  allowed_oauth_scopes                 = ["email", "openid"]

  supported_identity_providers = ["Google"]
  callback_urls = ["https://${var.cloudfront_distribution_domain_name}"]
  logout_urls   = ["https://${var.cloudfront_distribution_domain_name}"]
  # callback_urls = concat(
  #   ["https://${var.cloudfront_distribution_domain_name}"],
  #   var.env == "demo" ? ["https://www.workoutplanner.fit"] : []
  # )
  # logout_urls = concat(
  #   ["https://${var.cloudfront_distribution_domain_name}"],
  #   var.env == "demo" ? ["https://www.workoutplanner.fit"] : []
  # )
  
  # Ensures provider is created before the client uses it
  depends_on = [aws_cognito_identity_provider.google]
}
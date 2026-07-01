variable "env" {
  type        = string
  description = "The deployment environment (e.g., staging, prod)"
  default= "staging"
}

variable "project" {
  type        = string
  description = "Business project name"
}

variable "region" {
  type        = string
  description = "The AWS region to deploy resources"
  default     = "ap-east-1"
}

variable "is_alt_domain" {
  type        = bool
  description = "Enable alternative domain name"
  default     = false
}

variable "cloudfront_distribution_domain_name" {
  type        = string
  description = "The CloudFront distribution domain name"
}

variable "cognito_domain_name" {
  type        = string
  description = "The domain name for the Cognito User Pool"
  default     = ""
}

variable "cognito_domain_cert_arn" {
  type        = string
  description = "The ARN of the certificate for the Cognito User Pool domain"
  default     = ""
}

variable "is_cost_saving" {
  type        = bool
  description = "Enable cost saving features"
  default     = false

  validation {
    condition     = !(var.env == "prod" && var.is_cost_saving == true)
    error_message = "CRITICAL ERROR: Cost-saving features cannot be enabled ('is_cost_saving = true') in the production environment."
  }
}

data "aws_iam_account_alias" "current" {}

data "aws_caller_identity" "current" {}

locals {
  account_alias = data.aws_iam_account_alias.current.account_alias
  is_prod = var.env == "prod"
  name_prefix= "${var.env}-${var.project}"
}
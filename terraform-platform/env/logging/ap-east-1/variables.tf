variable "provider_profile" {
  type = string
  description = "The AWS profile to run the Terraform commands"
}

variable "log_account_id" {
  type = string
  description = "Log account id"
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

variable "demo_account_id" {
  type        = string
  description = "demo account id"
}

variable "dev_account_id" {
  type        = string
  description = "dev account id"
}

variable "uat_account_id" {
  type        = string
  description = "uat account id"
}

variable "prod_account_id" {
  type        = string
  description = "prod account id"
}

locals {
  demo_common_tags = {
    Project     = var.project
    Environment = "demo"
    ManagedBy   = "Terraform"
  }

  dev_common_tags = {
    Project     = var.project
    Environment = "dev"
    ManagedBy   = "Terraform"
  }

  uat_common_tags = {
    Project     = var.project
    Environment = "uat"
    ManagedBy   = "Terraform"
  }

  prod_common_tags = {
    Project     = var.project
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}
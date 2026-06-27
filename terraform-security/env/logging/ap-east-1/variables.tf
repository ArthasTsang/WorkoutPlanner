variable "provider_profile" {
  type = string
  description = "The AWS profile to run the Terraform commands"
}

variable "workload_account_id" {
  type = string
  description = "Workload account id"
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
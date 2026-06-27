terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  # default provider
  region = var.region
  profile = "${var.provider_profile}"
  assume_role {
	  role_arn     = "arn:aws:iam::${var.workload_account_id}:role/${var.project}-service-workout-${var.region}-terraform-role"
  }
  default_tags { tags = local.common_tags } 
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  alias = "demo"
  region = var.region
  profile = "${var.provider_profile}"
  assume_role {
	  role_arn     = "arn:aws:iam::${var.log_account_id}:role/${var.project}-logging-demo-${var.region}-terraform-role"
  }
  default_tags { tags = local.demo_common_tags } 
}

provider "aws" {
  alias = "dev"
  region = var.region
  profile = "${var.provider_profile}"
  assume_role {
	  role_arn     = "arn:aws:iam::${var.log_account_id}:role/${var.project}-logging-dev-${var.region}-terraform-role"
  }
  default_tags { tags = local.demo_common_tags } 
}

provider "aws" {
  alias = "uat"
  region = var.region
  profile = "${var.provider_profile}"
  assume_role {
	  role_arn     = "arn:aws:iam::${var.log_account_id}:role/${var.project}-logging-uat-${var.region}-terraform-role"
  }
  default_tags { tags = local.demo_common_tags } 
}

provider "aws" {
  alias = "prod"
  region = var.region
  profile = "${var.provider_profile}"
  assume_role {
	  role_arn     = "arn:aws:iam::${var.log_account_id}:role/${var.project}-logging-prod-${var.region}-terraform-role"
  }
  default_tags { tags = local.demo_common_tags } 
}
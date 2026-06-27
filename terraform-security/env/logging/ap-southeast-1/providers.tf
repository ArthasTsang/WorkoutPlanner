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
	  role_arn     = "arn:aws:iam::${var.workload_account_id}:role/OrganizationAccountAccessRole"
  }
  default_tags { tags = local.demo_common_tags } 
}

provider "aws" {
  alias = "dev"
  region = var.region
  profile = "${var.provider_profile}"
  assume_role {
	  role_arn     = "arn:aws:iam::${var.workload_account_id}:role/OrganizationAccountAccessRole"
  }
  default_tags { tags = local.dev_common_tags } 
}

provider "aws" {
  alias = "uat"
  region = var.region
  profile = "${var.provider_profile}"
  assume_role {
	  role_arn     = "arn:aws:iam::${var.workload_account_id}:role/OrganizationAccountAccessRole"
  }
  default_tags { tags = local.uat_common_tags } 
}

provider "aws" {
  alias = "prod"
  region = var.region
  profile = "${var.provider_profile}"
  assume_role {
	  role_arn     = "arn:aws:iam::${var.workload_account_id}:role/OrganizationAccountAccessRole"
  }
  default_tags { tags = local.prod_common_tags } 
}
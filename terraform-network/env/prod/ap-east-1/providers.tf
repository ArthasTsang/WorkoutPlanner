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
	  role_arn     = "arn:aws:iam::${var.network_account}:role/${var.project}-network-${var.region}-terraform-role"
  }
  default_tags { tags = local.common_tags } 
}

provider "aws" {
  alias = "prod_account"
  region = var.region
  profile = "${var.provider_profile}"
  assume_role {
    role_arn = "arn:aws:iam::${var.prod_account}:role/NetworkTeamCrossAccountRole"
  }
}
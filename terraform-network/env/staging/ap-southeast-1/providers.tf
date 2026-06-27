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
  alias = "demo_account"
  region = var.region
  profile = "${var.provider_profile}"
  assume_role {
    role_arn = "arn:aws:iam::${var.demo_account}:role/NetworkTeamCrossAccountRole"
  }
}

provider "aws" {
  alias = "dev_account"
  region = var.region
  profile = "${var.provider_profile}"
  assume_role {
    role_arn = "arn:aws:iam::${var.dev_account}:role/NetworkTeamCrossAccountRole"
  }
}

provider "aws" {
  alias = "uat_account"
  region = var.region
  profile = "${var.provider_profile}"
  assume_role {
    role_arn = "arn:aws:iam::${var.uat_account}:role/NetworkTeamCrossAccountRole"
  }
}
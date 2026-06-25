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
	  role_arn     = "arn:aws:iam::${var.network_account}:role/mwp-network-terraform-role"
  }
  default_tags { tags = local.common_tags } 
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  profile = "${var.provider_profile}"
  assume_role {
	  role_arn     = "arn:aws:iam::${var.network_account}:role/mwp-network-terraform-role"
  }
  default_tags { tags = local.common_tags } 
}

provider "aws" {
  alias = "demo_account"
  profile = "${var.provider_profile}"
  assume_role {
    role_arn = "arn:aws:iam::${var.demo_account}:role/NetworkTeamCrossAccountRole"
  }
}

provider "aws" {
  alias = "dev_account"
  profile = "${var.provider_profile}"
  assume_role {
    role_arn = "arn:aws:iam::${var.dev_account}:role/NetworkTeamCrossAccountRole"
  }
}

provider "aws" {
  alias = "uat_account"
  profile = "${var.provider_profile}"
  assume_role {
    role_arn = "arn:aws:iam::${var.uat_account}:role/NetworkTeamCrossAccountRole"
  }
}
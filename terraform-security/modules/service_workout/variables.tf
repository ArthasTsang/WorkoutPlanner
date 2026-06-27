variable "env" {
  type        = string
  description = "The deployment environment (e.g., dev, uat, prod)"
  default= "dev"
}

variable "project" {
  type        = string
  description = "Business project name"
}

variable "service" {
  type        = string
  description = "Microservice name"
}

variable "region" {
  type        = string
  description = "The AWS region to deploy resources"
  default     = "ap-east-1"
}

data "aws_iam_account_alias" "current" {}

data "aws_caller_identity" "current" {}

locals {
  account_alias = data.aws_iam_account_alias.current.account_alias
  account_id = data.aws_caller_identity.current.account_id
  is_prod = var.env == "prod"
  # name_prefix= "${var.project}"
  full_service_name = "${var.project}-service-${var.service}"
}
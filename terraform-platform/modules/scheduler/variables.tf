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

variable "docdb_cluster_arn" {
  type        = string
  description = "DocumentDB Cluster ARN"
}

variable "docdb_cluster_id" {
  type        = string
  description = "DocumentDB Cluster Identifier"
  
}

variable "is_startup_required" {
  type        = bool
  description = "No automatic startup required"
  default     = false
}

data "aws_iam_account_alias" "current" {}

data "aws_caller_identity" "current" {}

locals {
  account_alias = data.aws_iam_account_alias.current.account_alias
  account_id = data.aws_caller_identity.current.account_id
  is_prod = var.env == "prod"
  name_prefix= "${var.project}"
}
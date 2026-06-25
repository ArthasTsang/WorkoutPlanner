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

variable "network_account_id" {
  type        = string
  description = "Network account id"
}

variable "db_name" {
  type        = string
  description = "The name of the database"
  default     = "MyDB"
}

variable "requested_db_instance_count" {
  type        = number
  description = "The number of DB instances to request"
  default     = 2  
}

variable "is_create_from_snapshot" {
  type        = bool
  description = "Create from snapshot"
  default     = false
}

variable "snapshot_id" {
  type        = string
  description = "Snapshot ID"
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN"
}

data "aws_iam_account_alias" "current" {}

data "aws_caller_identity" "current" {}

locals {
  account_alias = data.aws_iam_account_alias.current.account_alias
  account_id = data.aws_caller_identity.current.account_id
  is_prod = var.env == "prod"
  max_db_instance_count = {
    demo = 2
    dev = 2
    uat = 2
    prod = 3
  }
  selected_max_db_instance_count = lookup(local.max_db_instance_count, var.env, 2)
  final_db_instance_count = min(var.requested_db_instance_count, local.selected_max_db_instance_count)
  name_prefix= "${var.project}"
}
variable "env" {
  type        = string
  description = "The deployment environment (e.g., staging, prod)"
  default= "staging"
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

variable "ecs_service_name" {
  type        = list(string)
  description = "ECS service name"
}

variable "blue_tg_name" {
  type        = list(string)
  description = "ECS blue target group name"
}

variable "green_tg_name" {
  type        = list(string)
  description = "ECS green target group name"
}


variable "is_cost_saving" {
  type        = bool
  description = "Enable cost saving features"
  default     = false

  validation {
    condition     = !(var.env == "prod" && var.is_cost_saving == true)
    error_message = "CRITICAL ERROR: Cost-saving features cannot be enabled ('is_cost_saving = true') in the production environment."
  }
}

data "aws_iam_account_alias" "current" {}

data "aws_caller_identity" "current" {}

locals {
  account_alias = data.aws_iam_account_alias.current.account_alias
  account_id = data.aws_caller_identity.current.account_id
  is_prod = var.env == "prod"
  name_prefix= "${var.project}"
  full_service_name = "${var.project}-service-${var.service}"
}
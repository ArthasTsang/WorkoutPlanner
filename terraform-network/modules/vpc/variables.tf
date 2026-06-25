# variable "dev_account" {
#   type = string
#   default = ""
# }

# variable "uat_account" {
#   type = string
#   default = ""
# }

# variable "prod_account" {
#   type = string
#   default = ""
# }

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

variable "vpc_cidr" {
  type        = string
  description = "The base CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "requested_az_count" {
  type        = number
  description = "Number of AZs"
  default     = 2
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

locals {
  is_prod = var.env == "prod"

  max_az_count = {
    staging  = 2
    prod = 3
  }
  selected_max_az_count = lookup(local.max_az_count, var.env, 2)
  final_az_count = min(var.requested_az_count, local.selected_max_az_count)

  max_nat_count = {
    staging  = 1
    prod = 3
  }
  final_nat_count = lookup(local.max_nat_count, var.env, 1)

  # Fetch available AZs for the target region
  all_azs = data.aws_availability_zones.available_az.names

  name_prefix= "${var.env}-${var.project}"
}

# Data source to fetch valid AZs dynamically
data "aws_availability_zones" "available_az" {
  state = "available"
}
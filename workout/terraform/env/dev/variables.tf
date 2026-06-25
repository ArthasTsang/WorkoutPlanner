variable "provider_profile" {
  type = string
  description = "The AWS profile to run the Terraform commands"
}

variable "workload_account_id" {
  type = string
  description = "Workload account id"
}

variable "env" {
  type        = string
  description = "The deployment environment (e.g., dev, uat, prod)"
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
  common_tags = {
    Project     = var.project
    Environment = var.env
    Service     = var.service
    ManagedBy   = "Terraform"
  }
}
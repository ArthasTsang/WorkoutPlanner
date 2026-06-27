variable "provider_profile" {
  type = string
  description = "The AWS profile to run the Terraform commands"
}

variable "workload_account_id" {
  type = string
  description = "Workload account id"
}

variable "log_account_id" {
  type = string
  description = "Log account id"
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

variable "region" {
  type        = string
  description = "The AWS region to deploy resources"
  default     = "ap-east-1"
}

variable "service" {
  type        = string
  description = "Microservice name"
}

locals {
  common_tags = {
    Project     = var.project
    Environment = var.env
    ManagedBy   = "Terraform"
  }
}
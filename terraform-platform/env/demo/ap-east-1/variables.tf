variable "provider_profile" {
  type = string
  description = "The AWS profile to run the Terraform commands"
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

variable "workload_account_id" {
  type = string
  description = "Workload account id"
}

variable "network_account_id" {
  type        = string
  description = "Network account id"
}

variable "log_account_id" {
  type        = string
  description = "Log account id"
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

variable "is_alt_domain" {
  type        = bool
  description = "Enable alternative domain name"
  default     = false
}

variable "alt_domain_name" {
  type        = string
  description = "The alternative domain name"
}

variable "domain_cert_arn" {
  type        = string
  description = "The domain certificate ARN"
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
    ManagedBy   = "Terraform"
  }
}
variable "provider_profile" {
  type = string
  default = "network-iamadmin"
}

variable "network_account" {
  type = string
  default = ""
}

variable "demo_account" {
  type = string
  default = ""
}

variable "dev_account" {
  type = string
  default = ""
}

variable "uat_account" {
  type = string
  default = ""
}

variable "env" {
  type        = string
  description = "The deployment environment (e.g., non-prod, prod)"
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
  description = "Turn on cost saving options"
  default     = false
}

locals {
  common_tags = {
    Project     = var.project
    Environment = var.env
    ManagedBy   = "Terraform"
  }
}
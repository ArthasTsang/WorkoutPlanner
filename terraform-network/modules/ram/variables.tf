variable "env" {
  type        = string
  description = "The network deployment environment (e.g., staging, prod)"
  default= "staging"
}

variable "workload_env" {
  type        = string
  description = "The workload sharing environment (e.g., dev, uat, prod)"
  default= "dev"
}

variable "project" {
  type        = string
  description = "Business project name"
}

variable "workload_account" {
  type = string
  default = ""
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to share via RAM"
}

variable "web_subnet_ids" {
  type        = list(string)
  description = "List of Web Subnet IDs to share via RAM"
}

variable "web_subnet_arns" {
  type        = list(string)
  description = "List of Web Subnet ARNs to share via RAM"
}

variable "app_subnet_ids" {
  type        = list(string)
  description = "List of App Subnet IDs to share via RAM"
}

variable "app_subnet_arns" {
  type        = list(string)
  description = "List of App Subnet ARNs to share via RAM"
}

variable "db_subnet_ids" {
  type        = list(string)
  description = "List of DB Subnet IDs to share via RAM"
}

variable "db_subnet_arns" {
  type        = list(string)
  description = "List of DB Subnet ARNs to share via RAM"
}

variable "alb_sg_id" {
  type        = string
  description = "ID of the ALB Security Group to share via RAM"
}

variable "alb_sg_arn" {
  type        = string
  description = "ARN of the ALB Security Group to share via RAM"
}

variable "app_sg_id" {
  type        = string
  description = "ID of the App Security Group to share via RAM"
}

variable "app_sg_arn" {
  type        = string
  description = "ARN of the App Security Group to share via RAM"
}

locals {
  is_prod = var.env == "prod"
  name_prefix= "${var.env}-${var.project}"
}
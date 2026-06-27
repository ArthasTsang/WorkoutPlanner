output "vpc" {
  description = "VPC"
  value       = aws_vpc.main
}

output "web_subnet" {
  description = "Web Subnets"
  value       = aws_subnet.web_subnet
}

output "app_subnet" {
  description = "App Subnets"
  value       = aws_subnet.app_subnet
}

output "db_subnet" {
  description = "DB Subnets"
  value       = aws_subnet.db_subnet
}

output "alb_sg" {
  description = "ALB Security Group"
  value       = aws_security_group.alb_sg
}

output "app_sg" {
  description = "App Security Group"
  value       = aws_security_group.app_sg
}

output "s3_gateway_endpoint" {
  description = "S3 gateway endpoint"
  value       = aws_vpc_endpoint.s3_gateway_endpoint.id
}

output "s3_gateway_endpoint_subnets" {
  description = "S3 gateway endpoint subnets"
  value       = aws_vpc_endpoint.s3_gateway_endpoint.subnet_ids
}

output "secrets_manager_vpc_endpoint" {
  description = "Secrets manager vpc endpoint"
  value       = aws_vpc_endpoint.secrets_manager_vpce[*].id
}

output "secrets_manager_vpc_endpoint_subnets" {
  description = "Secrets manager vpc endpoint subnets"
  value       = aws_vpc_endpoint.secrets_manager_vpce[*].subnet_ids
}

output "cloudwatch_metrics_vpc_endpoint" {
  description = "Cloudwatch metrics vpc endpoint"
  value       = aws_vpc_endpoint.cloudwatch_metrics[*].id
}

output "cloudwatch_metrics_vpc_endpoint_subnets" {
  description = "Cloudwatch metrics vpc endpoint subnets"
  value       = aws_vpc_endpoint.cloudwatch_metrics[*].subnet_ids
}

output "cloudwatch_logs_vpc_endpoint" {
  description = "Cloudwatch logs vpc endpoint"
  value       = aws_vpc_endpoint.cloudwatch_logs[*].id
}

output "cloudwatch_logs_vpc_endpoint_subnets" {
  description = "Cloudwatch logs vpc endpoint subnets"
  value       = aws_vpc_endpoint.cloudwatch_logs[*].subnet_ids
}
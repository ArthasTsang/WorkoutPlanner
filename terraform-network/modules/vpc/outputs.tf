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
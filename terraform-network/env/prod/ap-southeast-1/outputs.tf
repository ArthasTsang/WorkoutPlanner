output "vpc_id" {
  description = "VPC id"
  value       = module.network.vpc.id
}

output "vpc_cidr" {
  description = "VPC cidr"
  value       = module.network.vpc.cidr_block
}

output "web_subnet" {
  description = "Web Subnets"
  value       = module.network.web_subnet[*].id
}

output "app_subnet" {
  description = "App Subnets"
  value       = module.network.app_subnet[*].id
}

output "db_subnet" {
  description = "DB Subnets"
  value       = module.network.db_subnet[*].id
}

output "alb_sg" {
  description = "ALB Security Group"
  value       = module.network.alb_sg.name
}

output "app_sg" {
  description = "App Security Group"
  value       = module.network.app_sg.name
}

output "s3_gateway_endpoint" {
  description = "S3 gateway endpoint"
  value       = module.network.s3_gateway_endpoint
}

output "secrets_manager_vpc_endpoint" {
  description = "Secrets manager vpc endpoint"
  value       = module.network.secrets_manager_vpc_endpoint[*]
}

output "secrets_manager_vpc_endpoint_subnets" {
  description = "Secrets manager vpc endpoint subnets"
  value       = module.network.secrets_manager_vpc_endpoint_subnets[*]
}

# output "cloudwatch_metrics_vpc_endpoint" {
#   description = "Cloudwatch metrics vpc endpoint"
#   value       = module.network.cloudwatch_metrics_vpc_endpoint[*]
# }

# output "cloudwatch_metrics_vpc_endpoint_subnets" {
#   description = "Cloudwatch metrics vpc endpoint subnets"
#   value       = module.network.cloudwatch_metrics_vpc_endpoint_subnets[*]
# }

output "cloudwatch_logs_vpc_endpoint" {
  description = "Cloudwatch logs vpc endpoint"
  value       = module.network.cloudwatch_logs_vpc_endpoint[*]
}

output "cloudwatch_logs_vpc_endpoint_subnets" {
  description = "Cloudwatch logs vpc endpoint subnets"
  value       = module.network.cloudwatch_logs_vpc_endpoint_subnets[*]
}

output "xray_vpc_endpoint" {
  description = "X-Ray vpc endpoint"
  value       = module.network.xray_vpc_endpoint[*]
}

output "xray_vpc_endpoint_subnets" {
  description = "X-Ray vpc endpoint subnets"
  value       = module.network.xray_vpc_endpoint_subnets[*]
}

output "ecr_dkr_vpc_endpoint" {
  description = "ECR dkr vpc endpoint"
  value       = module.network.ecr_dkr_vpc_endpoint[*]
}

output "ecr_dkr_vpc_endpoint_subnets" {
  description = "ECR dkr vpc endpoint subnets"
  value       = module.network.ecr_dkr_vpc_endpoint_subnets[*]
}

output "ecr_api_vpc_endpoint" {
  description = "ECR api vpc endpoint"
  value       = module.network.ecr_api_vpc_endpoint[*]
}

output "ecr_api_vpc_endpoint_subnets" {
  description = "ECR api vpc endpoint subnets"
  value       = module.network.ecr_api_vpc_endpoint_subnets[*]
}

output "subnet_share" {
    description = "RAM resource share for subnets"
    value       = module.prod_ram_sharing.subnet_share
}

output "web_subnet_share" {
    description = "Shared web subnets"
    value       = module.prod_ram_sharing.web_subnet_share[*]
}

output "app_subnet_share" {
    description = "Shared app subnets"
    value       = module.prod_ram_sharing.app_subnet_share[*]
}

output "db_subnet_share" {
    description = "Shared db subnets"
    value       = module.prod_ram_sharing.db_subnet_share[*]
}

output "subnet_share_principals" {
    description = "Subnet shared principals"
    value       = module.prod_ram_sharing.subnet_share_principals
}

output "sg_share" {
    description = "RAM resource share for security groups"
    value       = module.prod_ram_sharing.sg_share
}

output "alb_sg_share" {
    description = "Shared ALB security group"
    value       = module.prod_ram_sharing.alb_sg_share
}

output "app_sg_share" {
    description = "Shared app security group"
    value       = module.prod_ram_sharing.app_sg_share
}

output "sg_share_principals" {
    description = "Security group shared principals"
    value       = module.prod_ram_sharing.sg_share_principals
}
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

output "demo_subnet_share" {
    description = "RAM resource share for subnets"
    value       = module.demo_ram_sharing.subnet_share
}

output "demo_web_subnet_share" {
    description = "Shared web subnets"
    value       = module.demo_ram_sharing.web_subnet_share[*]
}

output "demo_app_subnet_share" {
    description = "Shared app subnets"
    value       = module.demo_ram_sharing.app_subnet_share[*]
}

output "demo_db_subnet_share" {
    description = "Shared db subnets"
    value       = module.demo_ram_sharing.db_subnet_share[*]
}

output "demo_subnet_share_principals" {
    description = "Subnet shared principals"
    value       = module.demo_ram_sharing.subnet_share_principals
}

output "demo_sg_share" {
    description = "RAM resource share for security groups"
    value       = module.demo_ram_sharing.sg_share
}

output "demo_alb_sg_share" {
    description = "Shared ALB security group"
    value       = module.demo_ram_sharing.alb_sg_share
}

output "demo_app_sg_share" {
    description = "Shared app security group"
    value       = module.demo_ram_sharing.app_sg_share
}

output "demo_sg_share_principals" {
    description = "Security group shared principals"
    value       = module.demo_ram_sharing.sg_share_principals
}

output "dev_subnet_share" {
    description = "RAM resource share for subnets"
    value       = module.dev_ram_sharing.subnet_share
}

output "dev_web_subnet_share" {
    description = "Shared web subnets"
    value       = module.dev_ram_sharing.web_subnet_share[*]
}

output "dev_app_subnet_share" {
    description = "Shared app subnets"
    value       = module.dev_ram_sharing.app_subnet_share[*]
}

output "dev_db_subnet_share" {
    description = "Shared db subnets"
    value       = module.dev_ram_sharing.db_subnet_share[*]
}

output "dev_subnet_share_principals" {
    description = "Subnet shared principals"
    value       = module.dev_ram_sharing.subnet_share_principals
}

output "dev_sg_share" {
    description = "RAM resource share for security groups"
    value       = module.dev_ram_sharing.sg_share
}

output "dev_alb_sg_share" {
    description = "Shared ALB security group"
    value       = module.dev_ram_sharing.alb_sg_share
}

output "dev_app_sg_share" {
    description = "Shared app security group"
    value       = module.dev_ram_sharing.app_sg_share
}

output "dev_sg_share_principals" {
    description = "Security group shared principals"
    value       = module.dev_ram_sharing.sg_share_principals
}

output "uat_subnet_share" {
    description = "RAM resource share for subnets"
    value       = module.uat_ram_sharing.subnet_share
}

output "uat_web_subnet_share" {
    description = "Shared web subnets"
    value       = module.uat_ram_sharing.web_subnet_share[*]
}

output "uat_app_subnet_share" {
    description = "Shared app subnets"
    value       = module.uat_ram_sharing.app_subnet_share[*]
}

output "uat_db_subnet_share" {
    description = "Shared db subnets"
    value       = module.uat_ram_sharing.db_subnet_share[*]
}

output "uat_subnet_share_principals" {
    description = "Subnet shared principals"
    value       = module.uat_ram_sharing.subnet_share_principals
}

output "uat_sg_share" {
    description = "RAM resource share for security groups"
    value       = module.uat_ram_sharing.sg_share
}

output "uat_alb_sg_share" {
    description = "Shared ALB security group"
    value       = module.uat_ram_sharing.alb_sg_share
}

output "uat_app_sg_share" {
    description = "Shared app security group"
    value       = module.uat_ram_sharing.app_sg_share
}

output "uat_sg_share_principals" {
    description = "Security group shared principals"
    value       = module.uat_ram_sharing.sg_share_principals
}
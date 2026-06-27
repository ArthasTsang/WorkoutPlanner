output "subnet_share" {
    description = "RAM resource share for subnets"
    value       = aws_ram_resource_share.network_share.name
}

output "web_subnet_share" {
    description = "Shared web subnets"
    value       = aws_ram_resource_association.web_subnet_share[*].resource_arn
}

output "app_subnet_share" {
    description = "Shared app subnets"
    value       = aws_ram_resource_association.app_subnet_share[*].resource_arn
}

output "db_subnet_share" {
    description = "Shared db subnets"
    value       = aws_ram_resource_association.db_subnet_share[*].resource_arn
}

output "subnet_share_principals" {
    description = "Subnet shared principals"
    value       = aws_ram_principal_association.subnet_share_principal.id
}

output "sg_share" {
    description = "RAM resource share for security groups"
    value       = aws_ram_resource_share.sg_share.name
}

output "alb_sg_share" {
    description = "Shared ALB security group"
    value       = aws_ram_resource_association.alb_sg_association.resource_arn
}

output "app_sg_share" {
    description = "Shared app security group"
    value       = aws_ram_resource_association.app_sg_association.resource_arn
}

output "sg_share_principals" {
    description = "Security group shared principals"
    value       = aws_ram_principal_association.sg_share_principal.id
}
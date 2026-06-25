# Create a RAM resource share for subnets
resource "aws_ram_resource_share" "network_share" {
  name                      = "${var.workload_env}-network-share"
  allow_external_principals = false
}

resource "aws_ram_resource_association" "web_subnet_share" {
  count              = length(var.web_subnet_arns)
  resource_arn       = var.web_subnet_arns[count.index]
  resource_share_arn = aws_ram_resource_share.network_share.arn
}

resource "aws_ram_resource_association" "app_subnet_share" {
  count              = length(var.app_subnet_arns)
  resource_arn       = var.app_subnet_arns[count.index]
  resource_share_arn = aws_ram_resource_share.network_share.arn
}

resource "aws_ram_resource_association" "db_subnet_share" {
  count              = length(var.db_subnet_arns)
  resource_arn       = var.db_subnet_arns[count.index]
  resource_share_arn = aws_ram_resource_share.network_share.arn
}

resource "aws_ram_principal_association" "subnet_share_principal" {
  principal          = var.workload_account
  resource_share_arn = aws_ram_resource_share.network_share.arn
}

# Wait for the web subnets to be shared
resource "time_sleep" "wait_for_web_subnet_propagation" {
  create_duration = "30s"
  depends_on = [
    aws_ram_resource_association.web_subnet_share
  ]
}

# Wait for the app subnets to be shared
resource "time_sleep" "wait_for_app_subnet_propagation" {
  create_duration = "30s"
  depends_on = [
    aws_ram_resource_association.app_subnet_share
  ]
}

# Wait for the db subnets to be shared
resource "time_sleep" "wait_for_db_subnet_propagation" {
  create_duration = "30s"
  depends_on = [
    aws_ram_resource_association.db_subnet_share
  ]
}

# Add tags to the vpc in workload account
resource "aws_ec2_tag" "vpc_tag" {
  provider    = aws.workload_account
  resource_id = var.vpc_id
  key         = "Name"
  value       = "${local.name_prefix}-vpc"
  depends_on = [
    time_sleep.wait_for_web_subnet_propagation,
    time_sleep.wait_for_app_subnet_propagation,
    time_sleep.wait_for_db_subnet_propagation
  ]
}

# Add tags to the web subnets in workload account
resource "aws_ec2_tag" "web_subnet_tags" {
  count = length(var.web_subnet_ids)
  provider    = aws.workload_account
  resource_id = var.web_subnet_ids[count.index]
  key         = "Name"
  value       = "${local.name_prefix}-web-subnet-${count.index + 1}" 
  depends_on = [time_sleep.wait_for_web_subnet_propagation]
}

# Add tags to the app subnets in workload account
resource "aws_ec2_tag" "app_subnet_tags" {
  count = length(var.app_subnet_ids)
  provider    = aws.workload_account
  resource_id = var.app_subnet_ids[count.index]
  key         = "Name"
  value       = "${local.name_prefix}-app-subnet-${count.index + 1}" 
  depends_on = [time_sleep.wait_for_app_subnet_propagation]
}

# Add tags to the db subnets in workload account
resource "aws_ec2_tag" "db_subnet_tags" {
  count = length(var.db_subnet_ids)
  provider    = aws.workload_account
  resource_id = var.db_subnet_ids[count.index]
  key         = "Name"
  value       = "${local.name_prefix}-db-subnet-${count.index + 1}" 
  depends_on = [time_sleep.wait_for_db_subnet_propagation]
}

# Create a RAM resource share for security groups
resource "aws_ram_resource_share" "sg_share" {
  name = "${var.workload_env}-security-group-share"
  allow_external_principals = false
}

resource "aws_ram_resource_association" "alb_sg_association" {
  resource_arn = var.alb_sg_arn
  resource_share_arn = aws_ram_resource_share.sg_share.arn
}

resource "aws_ram_resource_association" "app_sg_association" {
  resource_arn = var.app_sg_arn
  resource_share_arn = aws_ram_resource_share.sg_share.arn
}

resource "aws_ram_principal_association" "sg_share_principal" {
  principal = var.workload_account
  resource_share_arn = aws_ram_resource_share.sg_share.arn
}

# Wait for the sg to be shared
resource "time_sleep" "wait_for_sg_propagation" {
  create_duration = "10s"
  depends_on = [
    aws_ram_resource_association.alb_sg_association,
    aws_ram_resource_association.app_sg_association
  ]
}

# Add tags to the alb security group
resource "aws_ec2_tag" "alb_sg_tag" {
  provider    = aws.workload_account
  resource_id = var.alb_sg_id
  key         = "Name"
  value       = "${local.name_prefix}-alb-sg"
  depends_on = [
    time_sleep.wait_for_sg_propagation
  ]
}

# Add tags to the app security group
resource "aws_ec2_tag" "app_sg_tag" {
  provider    = aws.workload_account
  resource_id = var.app_sg_id
  key         = "Name"
  value       = "${local.name_prefix}-app-sg"
  depends_on = [
    time_sleep.wait_for_sg_propagation
  ]
}
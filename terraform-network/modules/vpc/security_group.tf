data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

# Default security Group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
}

# ALB security Group
resource "aws_security_group" "alb_sg" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Allows public web traffic into the ALB"
  vpc_id      = aws_vpc.main.id

  tags = { 
    Name = "${local.name_prefix}-alb-sg" 
  }
}

# resource "aws_vpc_security_group_ingress_rule" "alb_sg_ingress_https" {
#   security_group_id = aws_security_group.alb_sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 8092
#   to_port           = 8092
#   ip_protocol       = "tcp"
#   description       = "Allow inbound HTTPS traffic from public"
# }

resource "aws_vpc_security_group_ingress_rule" "alb_sg_ingress_https" {
  security_group_id = aws_security_group.alb_sg.id
  from_port   = 8092
  to_port     = 8092
  ip_protocol        = "tcp"
  cidr_ipv4 = var.vpc_cidr
  description = "Allow inbound HTTPS traffic from VPC CIDR"
}

# Inbound rule consuming the Managed Prefix List (Weight: 55 rules)
resource "aws_vpc_security_group_ingress_rule" "alb_sg_ingress_cloudfront" {
  security_group_id = aws_security_group.alb_sg.id
  from_port       = 8092
  to_port         = 8092
  ip_protocol        = "tcp"
  prefix_list_id = data.aws_ec2_managed_prefix_list.cloudfront.id
  description       = "Allow inbound HTTPS traffic from CloudFront"
}

resource "aws_vpc_security_group_egress_rule" "alb_sg_egress_all" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"
}

# App Security Group
resource "aws_security_group" "app_sg" {
  name        = "${local.name_prefix}-app-sg"
  description = "Allows traffic only from Web ALB"
  vpc_id      = aws_vpc.main.id

  tags = { 
    Name = "${local.name_prefix}-app-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_sg_ingress_https" {
  security_group_id            = aws_security_group.app_sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = 8092
  to_port                      = 8092
  ip_protocol                  = "tcp"
  description                  = "Allow inbound HTTPS traffic from ALB"
}

resource "aws_vpc_security_group_egress_rule" "app_sg_egress_all" {
  security_group_id = aws_security_group.app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"
}

# # DB Security Group
# resource "aws_security_group" "db_sg" {
#   name        = "${local.name_prefix}-db-sg"
#   description = "Allows database traffic only from the App tier"
#   vpc_id      = aws_vpc.main.id

#   tags = { 
#     Name = "${local.name_prefix}-db-sg" 
#   }
# }

# resource "aws_vpc_security_group_ingress_rule" "db_sg_ingress_docdb" {
#   security_group_id            = aws_security_group.db_sg.id
#   referenced_security_group_id = aws_security_group.app_sg.id
#   from_port                    = 27017
#   to_port                      = 27017
#   ip_protocol                  = "tcp"
#   description                  = "Allow inbound DocumentDB traffic from app tier"
# }

# resource "aws_vpc_security_group_egress_rule" "db_sg_egress_all" {
#   security_group_id = aws_security_group.db_sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   ip_protocol       = "-1"
#   description       = "Allow all outbound traffic"
# }

# Secrets Manager security group
resource "aws_security_group" "secrets_manager_vpce_sg" {
  name        = "${local.name_prefix}-secrets-manager-vpce-sg"
  description = "Allows inbound HTTPS traffic from App tier to the Secrets Manager Endpoint"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-secrets-manager-vpce-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "secrets_manager_sg_ingress_https" {
  security_group_id            = aws_security_group.secrets_manager_vpce_sg.id
  referenced_security_group_id = aws_security_group.app_sg.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  description                  = "Allow inbound HTTPS traffic from app tier"
}

# Inbound rules for password rotation Lambda deployed in DB subnet
resource "aws_vpc_security_group_ingress_rule" "secrets_manager_sg_ingress_db_cidr" {
  for_each = { for idx, subnet in aws_subnet.db_subnet : idx => subnet.cidr_block }

  security_group_id = aws_security_group.secrets_manager_vpce_sg.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
  description       = "Allow inbound HTTPS from dev/uat account DB Subnet CIDR"
}

resource "aws_vpc_security_group_egress_rule" "secrets_manager_sg_egress_all" {
  security_group_id = aws_security_group.secrets_manager_vpce_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"
}

# CloudWatch Private Link security group
resource "aws_security_group" "cloudwatch_vpce_sg" {
  name        = "${local.name_prefix}-cloudwatch-vpce-sg"
  description = "Security group for CloudWatch VPC interface endpoint"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-cloudwatch-vpce-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "cloudwatch_vpce_sg_ingress_https" {
  security_group_id            = aws_security_group.cloudwatch_vpce_sg.id
  referenced_security_group_id = aws_security_group.app_sg.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  description                  = "Allow inbound HTTPS traffic from app tier"
}
  
resource "aws_vpc_security_group_egress_rule" "cloudwatch_vpce_sg_egress_all" {
  security_group_id = aws_security_group.cloudwatch_vpce_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"
}

# ECR Private Link security group
resource "aws_security_group" "ecr_vpce_sg" {
  name        = "${local.name_prefix}-ecr-vpce-sg"
  description = "Security group for ECR VPC interface endpoint"
  vpc_id      = aws_vpc.main.id

   tags = {
    Name = "${local.name_prefix}-ecr-vpce-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecr_vpce_sg_ingress_https" {
  security_group_id            = aws_security_group.ecr_vpce_sg.id
  referenced_security_group_id = aws_security_group.app_sg.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  description                  = "Allow inbound HTTPS traffic from app tier"
}
  
resource "aws_vpc_security_group_egress_rule" "ecr_vpce_sg_egress_all" {
  security_group_id = aws_security_group.ecr_vpce_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"
}
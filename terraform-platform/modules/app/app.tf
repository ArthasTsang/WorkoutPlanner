resource "random_password" "cloudfront_secret" {
  length  = 32
  special = false
}

# Application Load Balancer (ALB)
resource "aws_lb" "mwp_alb" {
  count = var.is_cost_saving ? 0 : 1
  
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.web_subnet.ids

  tags = { 
    Name = "${local.name_prefix}-alb"
  }
}

# ALB Listener
resource "aws_lb_listener" "http" {
  count = var.is_cost_saving ? 0 : 1

  load_balancer_arn = aws_lb.mwp_alb[count.index].arn
  port              = "8092"
  protocol          = "HTTP"

  # Path forwarding rules to be handled by service teams
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: Page Not Found"
      status_code  = "404"
    }
  }

  lifecycle {
    ignore_changes = [
      default_action
    ]
  }
}

# ECS cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${local.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = { 
    Name = "${local.name_prefix}-cluster"
  }
}

resource "aws_cloudwatch_log_group" "ecs_container_insights" {
  name              = "/aws/ecs/containerinsights/${local.name_prefix}-cluster/performance"
  retention_in_days = 7
}

# Share ALB listener ARN via SSM Parameter
resource "aws_ssm_parameter" "shared_alb_listener_arn" {
  count = var.is_cost_saving ? 0 : 1
  
  name        = "/platform/services/alb_listener_arn"
  type        = "String"
  tier        = "Standard"
  value       = aws_lb_listener.http[0].arn
  description = "Shared ALB listener ARN"
}

# Share CloudFront custom origin verify header via SSM Parameter
resource "aws_ssm_parameter" "shared_cloudfront_origin_header" {
  count = var.is_cost_saving ? 0 : 1
  
  name        = "/platform/services/cloudfront_origin_header"
  type        = "String"
  tier        = "Standard"
  value       = random_password.cloudfront_secret.result
  description = "CloudFront custom origin verify header"
}

# Share ECS cluster values via SSM Parameter
resource "aws_ssm_parameter" "shared_ec_cluster_id" {
  name        = "/platform/services/ec_cluster_id"
  type        = "String"
  tier        = "Standard"
  value       = aws_ecs_cluster.ecs_cluster.id
  description = "Shared ECS cluster id"
}

resource "aws_ssm_parameter" "shared_ec_cluster_name" {
  name        = "/platform/services/ec_cluster_name"
  type        = "String"
  tier        = "Standard"
  value       = aws_ecs_cluster.ecs_cluster.name
  description = "Shared ECS cluster name"
}

# Fetch the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"] # Restricts search to official AWS images

  # Filters for standard 64-bit architecture
  filter {
    name   = "name"
    values = ["al2023-ami-202*-kernel-6.1-x86_64"] 
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create the IAM Role for the EC2 instance
resource "aws_iam_role" "docdb_client_role" {
  name               = "${var.project}-${var.region}-docdb-client-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  permissions_boundary = "arn:aws:iam::${local.account_id}:policy/${var.project}-platform-${var.region}-scope-boundary-policy"
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core_attachment" {
  role       = aws_iam_role.docdb_client_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "docdb_connect_policy" {
  name = "docdb-connect-policy"
  role = aws_iam_role.docdb_client_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-db:connect"
        ]
        Resource = var.docdb_cluster_arn
      }
    ]
  })
}

# Build the Instance Profile wrapper
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project}-${var.region}-docdb-client-profile"
  role = aws_iam_role.docdb_client_role.name
}

# Launch template for EC2 instances
resource "aws_launch_template" "lt_mwp_workout" {
  name_prefix   = "${local.name_prefix}-db-client-template-"
  image_id      = data.aws_ami.amazon_linux_2023.id # Replace with your target Amazon Linux 2023 AMI ID
  instance_type = "t3.micro"
  update_default_version = true
  key_name = null
  vpc_security_group_ids = [data.aws_security_group.app_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = data.cloudinit_config.app_init.rendered

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${local.name_prefix}-docdb-client"
      Project     = "${var.project}"
      Environment = "${var.env}"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "cloudinit_config" "app_init" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "install_mongosh.sh"
    content_type = "text/x-shellscript"

    content = <<-SCRIPT
#!/bin/bash
set -ex

# 1. Use 'sudo tee' with unquoted EOF markers to write the repo file cleanly
echo "Create MongoDB repo file"
sudo tee /etc/yum.repos.d/mongodb-org-8.0.repo << 'EOF'
[mongodb-org-8.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/9/mongodb-org/8.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-8.0.asc
EOF

# 2. Flush and update metadata exclusively
echo "Install MongoDB"
sudo yum clean all
yum install -y mongodb-mongosh

# 3. Securely handle CA trust anchors inside the local home workspace
echo "Download RDS trust anchor"
mkdir -p /home/ec2-user
cd /home/ec2-user
wget https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem
chown -R ec2-user:ec2-user /home/ec2-user/global-bundle.pem
SCRIPT
  }
}
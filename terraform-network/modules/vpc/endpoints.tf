# Gateway Endpoints to S3
resource "aws_vpc_endpoint" "s3_gateway_endpoint" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  tags = { 
    Name = "${local.name_prefix}-s3-gateway-endpoint" 
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3_gateway_endpoint_association" {
  count = var.is_cost_saving ? 0 : local.final_az_count
  vpc_endpoint_id = aws_vpc_endpoint.s3_gateway_endpoint.id
  route_table_id  = aws_route_table.app_rt[count.index].id
}

# VPC Interface Endpoint to Secrets Manager
resource "aws_vpc_endpoint" "secrets_manager_vpce" {
  count = var.is_cost_saving ? 0 : 1

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  # Associates endpoint with app subnets
  # Associates with 1 subnet in staging for cost saving
  subnet_ids          = local.is_prod ? local.all_app_subnets : slice(local.all_app_subnets, 0, 1)
  security_group_ids  = [aws_security_group.secrets_manager_vpce_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "${local.name_prefix}-secrets-manager-vpce"
  }
}

# VPC Interface Endpoint to CloudWatch Metrics
resource "aws_vpc_endpoint" "cloudwatch_metrics" {
  count = var.is_cost_saving ? 0 : 1

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.monitoring"
  vpc_endpoint_type = "Interface"
  # Associates endpoint with app subnets
  # Associates with 1 subnet in staging for cost saving
  subnet_ids          = local.is_prod ? local.all_app_subnets : slice(local.all_app_subnets, 0, 1)
  security_group_ids = [aws_security_group.cloudwatch_vpce_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "${local.name_prefix}-cloudwatch-metrics-vpce"
  }
}

# VPC Interface Endpoint to CloudWatch Logs
resource "aws_vpc_endpoint" "cloudwatch_logs" {
  count = var.is_cost_saving ? 0 : 1

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type = "Interface"
  # Associates endpoint with app subnets
  # Associates with 1 subnet in staging for cost saving
  # When log size is expected to exceed 1GB per hour, cross-AZ data transfer will cost more than subnet association, switch to associate with all subnets
  subnet_ids          = local.is_prod ? local.all_app_subnets : slice(local.all_app_subnets, 0, 1)
  security_group_ids = [aws_security_group.cloudwatch_vpce_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "${local.name_prefix}-cloudwatch-logs-vpce"
  }
}



# 3. ECR DKR Endpoint (Required for docker pull and docker push)
resource "aws_vpc_endpoint" "ecr_dkr_vpce" {
  count = var.is_cost_saving ? 0 : 1

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  # Associates endpoint with app subnets
  # Associates with 1 subnet in staging for cost saving
  subnet_ids          = local.is_prod ? local.all_app_subnets : slice(local.all_app_subnets, 0, 1)
  security_group_ids  = [aws_security_group.ecr_vpce_sg.id]

  tags = {
    Name = "${local.name_prefix}-ecr-dkr-vpce"
  }
}

# 4. ECR API Endpoint (Required for IAM authentication & ECR API actions)
resource "aws_vpc_endpoint" "ecr_api_vpce" {
  count = var.is_cost_saving ? 0 : 1

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  # Associates endpoint with app subnets
  # Associates with 1 subnet in staging for cost saving
  subnet_ids          = local.is_prod ? local.all_app_subnets : slice(local.all_app_subnets, 0, 1)
  security_group_ids  = [aws_security_group.ecr_vpce_sg.id]

  tags = {
    Name = "${local.name_prefix}-ecr-api-vpce"
  }
}
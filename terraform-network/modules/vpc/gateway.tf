# Internet Gateways
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = { 
    Name = "${local.name_prefix}-igw"
  }
}

# EIP
resource "aws_eip" "nat_eip" {
  count = var.is_cost_saving ? 0 : local.final_nat_count
  domain = "vpc"

  tags = {
    Name = "${local.name_prefix}-nat-eip-${count.index+1}"
  }
  depends_on = [aws_internet_gateway.igw] 
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  count = var.is_cost_saving ? 0 : local.final_nat_count
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.web_subnet[count.index].id

  tags = { 
    Name = "${local.name_prefix}-nat-${count.index+1}"
  }
}
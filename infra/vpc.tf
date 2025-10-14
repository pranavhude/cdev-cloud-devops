# -----------------------------
# VPC - Network Configuration
# -----------------------------

# Create main VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project}-vpc"
  }
}

# Internet Gateway for public access
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project}-igw"
  }
}

# Get availability zones (AZs)
data "aws_availability_zones" "available" {
  state = "available"
}

# Public subnets (for Bastion & ALB)
resource "aws_subnet" "public" {
  for_each = toset(range(length(var.public_subnet_cidrs)))

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[each.value]
  availability_zone       = data.aws_availability_zones.available.names[each.value]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-public-${each.value}"
    Tier = "public"
  }
}

# Private subnets (for EKS & RDS)
resource "aws_subnet" "private" {
  for_each = toset(range(length(var.private_subnet_cidrs)))

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_subnet_cidrs[each.value]
  availability_zone       = data.aws_availability_zones.available.names[each.value]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project}-private-${each.value}"
    Tier = "private"
  }
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.project}-public-rt" }
}

# Default route for public subnets to Internet Gateway
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate public subnets to public route table
resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Elastic IP for NAT Gatewayesource "aws_eip" "nat" {
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project}-nat-eip"
  }
}

# NAT Gateway (for private subnet Internet access)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = element(aws_subnet.public.*.id, 0)

  tags = {
    Name = "${var.project}-nat"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Route table for private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.project}-private-rt" }
}

# Default route for private subnets to NAT Gateway
resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private_assoc" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}



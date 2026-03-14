# 1. The VPC (You already have this)
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true # Required for EKS
  enable_dns_support   = true

  tags = {
    Name = "FYP-VPC"
  }
}

# 2. The Internet Gateway (The "Front Door")
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# 3. Two Subnets (The "Parking Spots")
# EKS needs at least 2 for High Availability
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a" # Change to your region
  map_public_ip_on_launch = true

  tags = {
    Name = "FYP-Subnet-1"
    "kubernetes.io/role/elb" = "1" # Tells AWS to use this for Load Balancers
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b" # Change to your region
  map_public_ip_on_launch = true

  tags = {
    Name = "FYP-Subnet-2"
    "kubernetes.io/role/elb" = "1"
  }
}

# 4. Route Table (The "Directions")
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.rt.id
}
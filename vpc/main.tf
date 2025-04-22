resource "aws_vpc" "vpc" {
  cidr_block       = var.cidr_block_vpc

  tags = {
    Name = "VPC CICD"
    Owner = "Bruno"
  }
}

resource "aws_subnet" "public_subnets" {
  vpc_id = aws_vpc.vpc.id
  count = length(var.availability_zones)
  cidr_block = var.cidr_block_public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public subnet ${count.index + 1}"
    Owner = "Bruno"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "IGW - App CICD"
    Owner = "Bruno"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "RT public subnets"
  }
}

resource "aws_route_table_association" "rt_public_subnets_association" {
  count = length(var.availability_zones)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}
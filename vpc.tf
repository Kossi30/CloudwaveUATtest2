resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_subnet" "external" {
  count = length(slice(data.aws_availability_zones.az.names, 0, 2))

  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, length(slice(data.aws_availability_zones.az.names, 0, 2)) + count.index)
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = slice(data.aws_availability_zones.az.names, 0, 2)[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "external-${count.index + 1}"
  }
}

resource "aws_subnet" "internal" {
  count = length(slice(data.aws_availability_zones.az.names, 0, 2))

  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, length(slice(data.aws_availability_zones.az.names, 0, 3)) + count.index + 1)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = slice(data.aws_availability_zones.az.names, 0, 2)[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "internal-${count.index + 1}"
  }
}

resource "aws_subnet" "internal_db" {
  count = length(slice(data.aws_availability_zones.az.names, 0, 2))

  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, length(slice(data.aws_availability_zones.az.names, 0, 5)) + count.index + 1)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = slice(data.aws_availability_zones.az.names, 0, 2)[count.index]
  tags = {
    Name = "internal_db-${count.index + 1}"
  }
}
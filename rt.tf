
# --------------------------------------------------------------------------------------------------------------
#                     ROUTE TABLE
# --------------------------------------------------------------------------------------------------------------

resource "aws_route_table" "external_rt" {
  count  = length(slice(data.aws_availability_zones.az.names, 0, 2))
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "external_rt-${count.index + 1}"
  }
}
resource "aws_route_table_association" "a" {
  count = length(slice(data.aws_availability_zones.az.names, 0, 2))

  subnet_id      = element(aws_subnet.external.*.id, count.index)
  route_table_id = element(aws_route_table.external_rt.*.id, count.index)
}

resource "aws_route_table" "internal_rt" {
  count  = length(slice(data.aws_availability_zones.az.names, 0, 2))
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "internal_rt-${count.index}"
  }
}
resource "aws_route_table_association" "b" {
  count = length(slice(data.aws_availability_zones.az.names, 0, 2))

  subnet_id      = element(aws_subnet.internal.*.id, count.index)
  route_table_id = element(aws_route_table.internal_rt.*.id, count.index)
}

resource "aws_route_table" "internal_db_rt" {
  count  = length(slice(data.aws_availability_zones.az.names, 0, 2))
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "internal_rt-${count.index}"
  }
}
resource "aws_route_table_association" "c" {
  count = length(slice(data.aws_availability_zones.az.names, 0, 2))

  subnet_id      = element(aws_subnet.internal_db.*.id, count.index)
  route_table_id = element(aws_route_table.internal_db_rt.*.id, count.index)
}

# --------------------------------------------------------------------------------------------------------------
#                 Elastic IP configuration
# --------------------------------------------------------------------------------------------------------------
resource "aws_eip" "eip" {
  count = length(slice(data.aws_availability_zones.az.names, 0, 2))

  vpc        = true
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "eip_${count.index + 1}"
  }
}

# --------------------------------------------------------------------------------------------------------------
#                     NAT GATEWAY
# --------------------------------------------------------------------------------------------------------------

resource "aws_nat_gateway" "ngw" {
  count         = length(slice(data.aws_availability_zones.az.names, 0, 2))
  subnet_id     = element(aws_subnet.external.*.id, count.index)
  allocation_id = element(aws_eip.eip.*.id, count.index)
  tags = {
    Name = "Nat_Gateway_${count.index + 1}"
  }
}
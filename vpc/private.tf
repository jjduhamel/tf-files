resource "aws_subnet" "private" {
  count = "${ length(data.aws_availability_zones.az.names) }"
  vpc_id = "${ aws_vpc.vpc.id }"
  availability_zone = "${ element(data.aws_availability_zones.az.names, count.index) }"
  cidr_block = "${ cidrsubnet("10.0.0.0/16", 8, count.index+32) }"

  tags {
    Name = "Private Subnet ${ count.index+1 }"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${ aws_vpc.vpc.id }"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${ aws_nat_gateway.nat-gateway.id }"
  }

  tags {
    Name = "Private Route Table"
  }
}

resource "aws_route_table_association" "private" {
  count = "${ length(aws_subnet.private.*.id) }"
  subnet_id = "${ element(aws_subnet.private.*.id, count.index) }"
  route_table_id = "${ aws_route_table.private.id }"
}

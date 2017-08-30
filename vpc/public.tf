resource "aws_subnet" "public" {
  count = "${ length(data.aws_availability_zones.az.names) }"
  vpc_id = "${ aws_vpc.vpc.id }"
  availability_zone = "${ element(data.aws_availability_zones.az.names, count.index) }"
  cidr_block = "${ cidrsubnet("10.0.0.0/16", 8, count.index+10) }"

  tags {
    Name = "Public Subnet ${ count.index+1 }"
  }

  map_public_ip_on_launch = true
}

resource "aws_route_table" "public" {
  vpc_id = "${ aws_vpc.vpc.id }"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${ aws_internet_gateway.public-gateway.id }"
  }

  tags {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public" {
  count = "${ length(aws_subnet.public.*.id) }"
  subnet_id = "${ element(aws_subnet.public.*.id, count.index) }"
  route_table_id = "${ aws_route_table.public.id }"
}

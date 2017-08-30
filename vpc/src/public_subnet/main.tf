variable "vpc_id" {}
variable "availability_zones" { default = [] }

resource "aws_internet_gateway" "public" {
  vpc_id = "${ var.vpc_id }"

  tags {
    Name = "Public Gateway"
  }
}

resource "aws_subnet" "public" {
  count = "3"
  vpc_id = "${ var.vpc_id }"
  availability_zone = "${ element(var.availability_zones, count.index) }"
  cidr_block = "${ cidrsubnet("10.0.0.0/16", 8, count.index+10) }"

  tags {
    Name = "Public Subnet ${ count.index+1 }"
  }

  map_public_ip_on_launch = true
}

resource "aws_route_table" "public" {
  vpc_id = "${ var.vpc_id }"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${ aws_internet_gateway.public.id }"
  }

  tags {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public" {
  count = "3"
  subnet_id = "${ element(aws_subnet.public.*.id, count.index) }"
  route_table_id = "${ aws_route_table.public.id }"
}

output "subnet_ids" { value = "${ aws_subnet.public.*.id }" }

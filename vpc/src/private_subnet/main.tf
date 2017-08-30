variable "vpc_id" {}
variable "availability_zones" { default = [] }
variable "nat_gateway_id" {}

resource "aws_subnet" "private" {
  count = "${ length(var.availability_zones) }"
  vpc_id = "${ var.vpc_id }"
  availability_zone = "${ element(var.availability_zones, count.index) }"
  cidr_block = "${ cidrsubnet("10.0.0.0/16", 8, count.index+32) }"

  tags {
    Name = "Private Subnet ${ count.index+1 }"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${ var.vpc_id }"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${ var.nat_gateway_id }"
  }

  tags {
    Name = "Private Route Table"
  }
}

resource "aws_route_table_association" "private" {
  count = "${ length(var.availability_zones) }"
  subnet_id = "${ element(aws_subnet.private.*.id, count.index) }"
  route_table_id = "${ aws_route_table.private.id }"
}

output "subnet_ids" { value = "${ aws_subnet.private.*.id }" }

resource "aws_internet_gateway" "public-gateway" {
  vpc_id = "${ aws_vpc.vpc.id }"

  tags {
    Name = "Public Gateway"
  }
}

resource "aws_eip" "nat-eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = "${ aws_eip.nat-eip.id }"
  subnet_id = "${ element(aws_subnet.public.*.id, 0) }"
}

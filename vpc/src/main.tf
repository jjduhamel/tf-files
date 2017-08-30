variable "name" { default = "Primary VPC" }
variable "availability_zones" { default = [] }

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags {
    Name = "${ var.name }"
  }
}

module "public_subnets" {
  source = "./public_subnet"
  vpc_id = "${ aws_vpc.vpc.id }"
  availability_zones = "${ var.availability_zones }"
}

resource "aws_eip" "nat-eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = "${ aws_eip.nat-eip.id }"
  subnet_id = "${ element(module.public_subnets.subnet_ids, 0) }"
}

module "private_subnets" {
  source = "./private_subnet"
  vpc_id = "${ aws_vpc.vpc.id }"
  availability_zones = "${ var.availability_zones }"
  nat_gateway_id = "${ aws_nat_gateway.nat-gateway.id }"
}

output "vpc_id" { value = "${ aws_vpc.vpc.id }" }
output "public_subnets" { value = "${ module.public_subnets.subnet_ids }" }
output "private_subnets" { value = "${ module.private_subnets.subnet_ids }" }

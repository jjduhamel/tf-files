variable "region" { default = "us-west-2" }

terraform {
  backend "s3" {
    bucket = "hbpcb-terraform"
    key = "vpc/terraform.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
}

data "aws_availability_zones" "az" {}

output "vpc_id" { value = "${ aws_vpc.vpc.id }" }
output "public_subnets" { value = "${ aws_subnet.public.*.id }" }
output "private_subnets" { value = "${ aws_subnet.private.*.id }" }

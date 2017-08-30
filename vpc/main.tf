variable "region" { default = "us-west-2" }

terraform {
  backend "s3" {
    bucket = "hbpcb-terraform"
    key = "vpc/terraform.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "${ var.region }"
}

data "aws_availability_zones" "available" {
}

module "vpc" {
  source = "./src"
  name = "Primary VPC"
  availability_zones = "${ data.aws_availability_zones.available.names }"
}

output "vpc_id" { value = "${ module.vpc.vpc_id }" }
output "public_subnets" { value = "${ module.vpc.public_subnets }" }
output "private_subnets" { value = "${ module.vpc.private_subnets }" }

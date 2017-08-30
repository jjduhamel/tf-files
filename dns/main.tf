provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "hbpcb-terraform"
    key = "dns/terraform.tfstate"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config {
    bucket = "hbpcb-terraform"
    key    = "vpc/terraform.tfstate"
    region = "us-west-2"
  }
}

data "aws_vpc" "vpc" {
  id = "${ data.terraform_remote_state.vpc.vpc_id }"
}

resource "aws_route53_delegation_set" "public" {}

resource "aws_route53_zone" "public" {
  name = "homebrewpcb.com"
  delegation_set_id = "${ aws_route53_delegation_set.public.id }"
}

resource "aws_route53_zone" "private" {
  name = "homebrewpcb.com"
  vpc_id =  "${ data.aws_vpc.vpc.id }"
}

output "public_zone" { value = "${ aws_route53_zone.public.zone_id }" }
output "private_zone" { value = "${ aws_route53_zone.private.zone_id }" }

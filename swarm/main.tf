variable "region" { default="us-west-2" }
variable "ami_id" { default="ami-9fe6f8e6" }
variable "ami_user" { default="core" }
variable "manager_instance_type" { default="t2.micro" }
variable "worker_instance_type" { default="t2.micro" }
variable "keypair" {}

provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "hbpcb-terraform"
    key = "swarm/terraform.tfstate"
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

data "aws_vpc" "primary" {
  id = "${ data.terraform_remote_state.vpc.vpc_id }"
}

data "aws_subnet" "private" {
  id = "${ element(data.terraform_remote_state.vpc.public_subnets, 0) }"
}

data "terraform_remote_state" "dns" {
  backend = "s3"
  config {
    bucket = "hbpcb-terraform"
    key    = "dns/terraform.tfstate"
    region = "us-west-2"
  }
}

resource "aws_route53_record" "swarm" {
  zone_id = "${ data.terraform_remote_state.dns.private_zone }"
  name = "swarm.homebrewpcb.com"
  type = "A"
  ttl = "300"
  records = [ "${ aws_instance.manager.private_ip }" ]
}

output "managers" { value = [ "${ aws_instance.manager.private_ip }" ] }
output "workers" { value = [ "${ aws_instance.worker.*.private_ip }" ] }

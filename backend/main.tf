variable "region" { default = "us-west-2" }

terraform {
  backend "s3" {
    bucket = "hbpcb-terraform"
    key = "backend/terraform.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "${ var.region }"
}

resource "aws_s3_bucket" "hbpcb-terraform" {
  bucket = "hbpcb-terraform"
  region = "${ var.region }"

  versioning {
    enabled = true
  }
}

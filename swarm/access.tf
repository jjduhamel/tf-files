data "terraform_remote_state" "credstash" {
  backend = "s3"
  config {
    bucket = "hbpcb-terraform"
    key    = "credstash/terraform.tfstate"
    region = "us-west-2"
  }
}

resource "aws_iam_instance_profile" "swarm" {
  name = "swarm"
  role = "${ data.terraform_remote_state.credstash.iam_role }"
}

resource "aws_security_group" "swarm" {
  name = "swarm"
  vpc_id = "${ data.aws_vpc.primary.id }"
  description = "Security group for Docker Swarm Manager"
  tags { Name = "Docker Swarm" }

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    protocol = "tcp"
    from_port = 2375
    to_port = 2375
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    protocol = "tcp"
    from_port = 2377
    to_port = 2377
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    protocol = "tcp"
    from_port = 7946
    to_port = 7946
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    protocol = "udp"
    from_port = 7946
    to_port = 7946
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    protocol = "udp"
    from_port = 4789
    to_port = 4789
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

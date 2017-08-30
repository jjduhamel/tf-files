variable "keypair" { default="" }

provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "hbpcb-terraform"
    key = "openvpn/terraform.tfstate"
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

data "aws_subnet" "public" {
  id = "${ element(data.terraform_remote_state.vpc.public_subnets, 0) }"
}

data "terraform_remote_state" "credstash" {
  backend = "s3"
  config {
    bucket = "hbpcb-terraform"
    key    = "credstash/terraform.tfstate"
    region = "us-west-2"
  }
}

data "aws_iam_role" "credstash" {
  name = "${ data.terraform_remote_state.credstash.iam_role }"
}

data "terraform_remote_state" "dns" {
  backend = "s3"
  config {
    bucket = "hbpcb-terraform"
    key    = "dns/terraform.tfstate"
    region = "us-west-2"
  }
}

data "aws_route53_zone" "public" {
  zone_id = "${ data.terraform_remote_state.dns.public_zone }"
}

data "aws_ami" "debian" {
  most_recent = true

  name_regex = "hbpcb-debian"
  owners = [ "self" ]
}

resource "aws_security_group" "openvpn" {
  name = "openvpn"
  vpc_id = "${ data.aws_vpc.vpc.id }"
  description = "OpenVPN (UDP)"
  tags { Name = "OpenVPN" }

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    protocol = "udp"
    from_port = 1194
    to_port = 1194
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_iam_instance_profile" "openvpn" {
  name = "openvpn"
  role = "${ data.terraform_remote_state.credstash.iam_role }"
}

resource "aws_instance" "openvpn" {
  ami = "${ data.aws_ami.debian.id }"
  instance_type = "t2.micro"
  key_name = "${ var.keypair }"
  iam_instance_profile = "${ aws_iam_instance_profile.openvpn.id }"
  subnet_id = "${ data.aws_subnet.public.id }"
  vpc_security_group_ids = [ "${ aws_security_group.openvpn.id }" ]
  tags { Name = "OpenVPN" }

  connection {
    type = "ssh"
    user = "admin"
    private_key = "${ file("~/.ssh/id_rsa") }"
    host = "${ aws_instance.openvpn.public_ip }"
  }

  provisioner "file" {
    source = "${ path.module }/fs"
    destination = "/tmp/fs"
  }

  provisioner "remote-exec" {
    inline = [
      "set -x",
      "sudo apt-get update",
      "sudo cp -vr /tmp/fs/etc/* /etc",
      "sudo rm -vrf /tmp/fs",
      "sudo touch /etc/openvpn/ca.crt",
      "sudo touch /etc/openvpn/server.crt",
      "sudo touch /etc/openvpn/server.key",
      "sudo openssl dhparam -out /etc/openvpn/dh2048.pem 2048",
      "sudo sed -i 's/#net.ipv4.ip_forward.*=.*1/net.ipv4.ip_forward=1/' /etc/sysctl.conf",
      "sudo sysctl -p",
      "sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE",
      "sudo iptables-save > /etc/iptables/rules.v4",
      "echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections",
      "echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections",
      "sudo apt-get install -y openvpn iptables-persistent",
      "credstash -r us-west-2 get VPN_CA_CERT | sudo tee /etc/openvpn/ca.crt > /dev/null",
      "credstash -r us-west-2 get VPN_SERVER_CERT | sudo tee /etc/openvpn/server.crt > /dev/null",
      "credstash -r us-west-2 get VPN_SERVER_KEY | sudo tee /etc/openvpn/server.key > /dev/null",
			"sudo systemctl daemon-reload",
      "sudo systemctl enable openvpn@local",
      "sudo systemctl start openvpn@local",
      "set +x"
    ]
  }
}

resource "aws_eip" "openvpn" {
  instance = "${ aws_instance.openvpn.id }"
}

resource "aws_route53_record" "openvpn" {
  zone_id = "${ data.aws_route53_zone.public.zone_id }"
  name = "ovpn.homebrewpcb.com"
  type = "A"
  ttl = "300"
  records = [ "${ aws_eip.openvpn.public_ip }" ]
}

output "ip_address" { value = "${ aws_eip.openvpn.public_ip }" }
output "ami_id" { value = "${ data.aws_ami.debian.id }" }
output "vpc_id" { value = "${ data.aws_vpc.vpc.id }" }
output "subnet_id" { value = "${ data.aws_subnet.public.id }" }

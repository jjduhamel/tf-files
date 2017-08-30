resource "aws_instance" "manager" {
  ami = "${ var.ami_id }"
  key_name = "${ var.keypair }"
  instance_type = "${ var.manager_instance_type }"
  subnet_id = "${ data.aws_subnet.private.id }"
  vpc_security_group_ids = [ "${ aws_security_group.swarm.id }" ]
  iam_instance_profile = "${ aws_iam_instance_profile.swarm.id }"
  user_data = "${ data.ignition_config.swarm.rendered }"
  tags { Name = "Swarm Manager" }

  connection {
    type = "ssh"
    user = "${ var.ami_user }"
    private_key = "${ file("~/.ssh/id_rsa") }"
  }

  provisioner "remote-exec" {
    inline = [
      "set -x",
      "docker pull coxauto/credstash",
      "docker swarm init --advertise-addr eth0:2377",
			"docker swarm join-token -q worker | xargs docker run coxauto/credstash credstash -r ${ var.region } put SWARM_WORKER_TOKEN -v $(date +%s)",
      "sudo mkdir -p /etc/certs/swarm",
      "docker run credstash credstash -r ${ var.region } get VPN_CA_CERT | sudo tee /etc/certs/ca.crt > /dev/null",
      "docker run coxauto/credstash credstash -r ${ var.region } get SWARM_SERVER_CERT | sudo tee /etc/certs/swarm/domain.crt > /dev/null",
      "docker run coxauto/credstash credstash -r ${ var.region } get SWARM_SERVER_KEY | sudo tee /etc/certs/swarm/domain.key > /dev/null",
      "echo \"127.0.0.1       swarm.homebrewpcb.com\" | sudo tee -a /etc/hosts >> /dev/null",
      "set +x"
    ]
  }
}

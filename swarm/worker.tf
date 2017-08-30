variable "worker_count" { default=0 }

resource "aws_instance" "worker" {
	depends_on = [ "aws_instance.manager" ]
  count = "${ var.worker_count }"

  ami = "${ var.ami_id }"
  key_name = "${ var.keypair }"
  instance_type = "${ var.worker_instance_type }"
  subnet_id = "${ data.aws_subnet.private.id }"
  vpc_security_group_ids = [ "${ aws_security_group.swarm.id }" ]
  iam_instance_profile = "${ aws_iam_instance_profile.swarm.id }"
  user_data = "${ data.ignition_config.swarm.rendered }"
  tags { Name = "Swarm Worker ${ count.index }" }

  connection {
    type = "ssh"
    user = "${ var.ami_user }"
    private_key = "${ file("~/.ssh/id_rsa") }"
  }

  provisioner "remote-exec" {
    inline = [
      "set -x",
      "docker pull coxauto/credstash",
			"export SWARM_WORKER_TOKEN=$(docker run coxauto/credstash credstash -r ${ var.region } get SWARM_WORKER_TOKEN)",
			"docker swarm join --token $SWARM_WORKER_TOKEN ${ aws_instance.manager.private_ip }:2377",
      "set +x"
    ]
  }
}

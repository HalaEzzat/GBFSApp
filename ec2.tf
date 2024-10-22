resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.gbfs_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ec2-security-group" }
}

resource "aws_instance" "docker_instance" {
  ami                    = "ami-0b898040803850657"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = tls_private_key.id_rsa.key_name
  associate_public_ip_address = true

  tags = { Name = "Docker Instance" }
}

resource "null_resource" "docker_setup" {
  provisioner "file" {
    connection {
      host        = aws_instance.docker_instance.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = var.ssh_private_key
    }

    source      = "./app"
    destination = "/tmp/app"
  }

  provisioner "remote-exec" {
    connection {
      host        = aws_instance.docker_instance.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = var.ssh_private_key
    }

    inline = [
      "sudo amazon-linux-extras install docker -y",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "cd /tmp/app",
      "docker-compose version",
      "sudo /usr/local/bin/docker-compose up -d"
    ]
  }

  depends_on = [aws_instance.docker_instance]
}

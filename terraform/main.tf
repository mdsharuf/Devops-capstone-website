terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Security group for instances
resource "aws_security_group" "capstone_sg" {
  name        = "capstone-sg"
  description = "Allow SSH, NodePort, Kubernetes control plane"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  ingress {
    description = "NodePort (app)"
    from_port   = 30008
    to_port     = 30008
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes API (6443)"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "capstone-sg"
  }
}

# Lookup default VPC (works in most accounts). If you want a specific VPC, change this.
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

# EC2 instances for workers
resource "aws_instance" "worker" {
  count         = 4
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = element(data.aws_subnet_ids.default.ids, count.index % length(data.aws_subnet_ids.default.ids))
  vpc_security_group_ids = [aws_security_group.capstone_sg.id]

  tags = {
    Name = "worker-${count.index + 1}"
    Role = element(["jenkins","worker2","master","worker4"], count.index)
  }

  # Keep user_data minimal because Ansible will configure everything
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y apt-transport-https ca-certificates curl
              EOF

  # Wait for SSH to be available before terraform considers it done (useful)
  provisioner "remote-exec" {
    inline = ["echo instance ${self.tags["Name"]} ready"]
    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.private_key_path)
      host        = self.public_ip
      timeout     = "2m"
    }
  }
}

# Optional: create an outputs file with public IPs
output "public_ips" {
  value = aws_instance.worker[*].public_ip
}

output "private_ips" {
  value = aws_instance.worker[*].private_ip
}

output "names" {
  value = aws_instance.worker[*].tags
}

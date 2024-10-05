# Define the SSH key pair resource
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"             
  rsa_bits  = 2048                   
}

resource "local_file" "foo" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/keypair.pem"
}

# key pair info to access the instance
resource "aws_key_pair" "this" {
 key_name   = "rundeck-key"
 public_key = tls_private_key.ssh_key.public_key_openssh
}

# the EC2 instance details
resource "aws_instance" "this" {
 ami                         = var.ami_id
 subnet_id                   = var.subnet_id
 instance_type               = "t3.medium"
 key_name                    = aws_key_pair.this.key_name
 vpc_security_group_ids      = ["${aws_security_group.secgroup-this.id}"]
 private_ip                  = var.private_instance_ip 

 # install and configure rundeck on docker, then enables and launch the service
 # user: admin, password: admin
 user_data                   = <<-EOF
#!/bin/bash
# Update the system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Docker & Docker Compose
# Install Docker
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
export EXTERNAL_IP=$(curl http://checkip.amazonaws.com)

mkdir rundeck-demo && cd rundeck-demo
cat <<COMPOSE > docker-compose.yml
version: '3'

services:
    rundeck:
        image: rundeck/rundeck:5.6.0
        links:
          - postgres
        environment:
            RUNDECK_DATABASE_DRIVER: org.postgresql.Driver
            RUNDECK_DATABASE_USERNAME: ${var.db_username}
            RUNDECK_DATABASE_PASSWORD: ${var.db_password}
            RUNDECK_DATABASE_URL: jdbc:postgresql://${var.db_host}/rundeck?autoReconnect=true&useSSL=false&allowPublicKeyRetrieval=true
            RUNDECK_GRAILS_URL: http://${var.private_instance_ip}:4440
        ports:
          - 4440:4440
        volumes:
          - rundeck-data:/home/rundeck/server/data

volumes:
    rundeck-data:

COMPOSE

sudo docker-compose up -d

  EOF
 associate_public_ip_address = false

 # 10gb disk instance
 root_block_device {
   volume_size = 10
 }

 # EC2 instance tags
 tags = {
   Name        = "Rundeck EC2 Deployment"
   Description = "Rundeck Terraform Deployment EC2 instance"
 }
}

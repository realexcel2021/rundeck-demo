# AWS Security Group
resource "aws_security_group" "secgroup-this" {
 depends_on  = [var.vpc_id]
 name        = "secgroup-rundeck"
 description = "Security Group for Rundeck Terraform Deployment"
 vpc_id      = var.vpc_id
 tags = {
   Name = "Rundeck Terraform Deployment Security Group"
 }
}

# Rundeck (port 4440 by default)
resource "aws_security_group_rule" "rundeck" {
 type              = "ingress"
 description       = "rundeck"
 from_port         = 4440
 to_port           = 4440
 protocol          = "tcp"
 cidr_blocks       = ["0.0.0.0/0"]
 security_group_id = aws_security_group.secgroup-this.id
}

# SSH service (port 22)
resource "aws_security_group_rule" "ssh" {
 type              = "ingress"
 description       = "ssh"
 from_port         = 22
 to_port           = 22
 protocol          = "tcp"
 cidr_blocks       = ["0.0.0.0/0"]
 security_group_id = aws_security_group.secgroup-this.id
}

# outcoming rule to "all", only for testing, the aim is to restrict the access to some "allowed" clients.
resource "aws_security_group_rule" "all" {
 type              = "egress"
 description       = "all"
 from_port         = 0
 to_port           = 0
 protocol          = "-1"
 cidr_blocks       = ["0.0.0.0/0"]
 security_group_id = aws_security_group.secgroup-this.id
}

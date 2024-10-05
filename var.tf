variable "region" {
  default = "eu-west-2"
}

variable "vpc_id" {
  type = string
  default = "vpc-0d234c4d0b0ce06ec"
}

variable "ami_id" {
  type = string
  default = "ami-0e8d228ad90af673b"
}

# default availability zone
variable "zone_a" {
 default = "eu-west-2a"
}

variable "subnet_id" {
  type = string
  default = "subnet-08c9c399f5d7a5b94"
}

variable "private_instance_ip" {
  type = string
  default = "10.0.101.10"
}

variable "db_host" {
  type = string
  default = "postgres"
}

variable "db_username" {
  type = string
  default = "rundeck"
}

variable "db_password" {
  type = string
  sensitive = true
  default = "rundeck"
}
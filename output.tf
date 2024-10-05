output "public_ip" {
 value       = aws_instance.this.public_ip
 description = "Rundeck Instance Public IP"
}
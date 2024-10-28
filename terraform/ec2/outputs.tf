# Output for App Instance Public IPs
output "app_instance_public_ips" {
  description = "Public IPs of the app instances"
  value       = aws_instance.app_instance[*].public_ip
}

# Output for Database Instance Public IP
output "db_instance_public_ip" {
  description = "Public IP of the database instance"
  value       = aws_instance.db_instance.public_ip
}

# Output for Database Instance Private IP
output "db_instance_private_ip" {
  description = "Private IP of the database instance"
  value       = aws_instance.db_instance.private_ip
}

output "db_host" {
  value = aws_instance.db_instance.public_dns
}

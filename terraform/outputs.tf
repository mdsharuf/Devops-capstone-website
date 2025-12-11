output "workers_public_ips" {
  value = aws_instance.worker[*].public_ip
  description = "Public IPs of all 4 workers (index 0..3 correspond to worker1..worker4)"
}

output "workers_private_ips" {
  value = aws_instance.worker[*].private_ip
  description = "Private IPs of all 4 workers"
}

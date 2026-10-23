output "security_group_id" {
  description = "ID of the Kubernetes security group"
  value       = aws_security_group.k8s.id
}
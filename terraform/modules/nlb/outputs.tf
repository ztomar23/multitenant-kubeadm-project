output "nlb_dns_name" {
  description = "Public DNS name of the Kubernetes Network Load Balancer"
  value       = aws_lb.k8s.dns_name
}

output "nlb_zone_id" {
  description = "Canonical hosted zone ID of the Network Load Balancer"
  value       = aws_lb.k8s.zone_id
}

output "nlb_security_group_id" {
  description = "Security group attached to the Network Load Balancer"
  value       = aws_security_group.nlb.id
}


output "control_plane_instance_id" {
  description = "Kubernetes control plane EC2 instance ID"
  value       = module.ec2.control_plane_instance_id
}

output "worker1_instance_id" {
  description = "Kubernetes worker EC2 instance ID"
  value       = module.ec2.worker1_instance_id
}

output "nlb_dns_name" {
  description = "Public DNS name of the Kubernetes Network Load Balancer"
  value       = module.nlb.nlb_dns_name
}

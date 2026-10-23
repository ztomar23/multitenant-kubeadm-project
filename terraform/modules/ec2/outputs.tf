output "ubuntu_ami_id" {
  description = "ID of the selected Ubuntu AMI"
  value       = var.ami_id
}
output "control_plane_instance_id" {
  description = "ID of the Kubernetes control plane EC2 instance"
  value       = aws_instance.control_plane.id
}

output "worker1_instance_id" {
  description = "ID of the Kubernetes worker1 EC2 instance"
  value       = aws_instance.worker1.id
}

variable "vpc_id" {
  description = "ID of the Kubernetes VPC"
  type        = string
}

variable "subnet_id" {
  description = "Public subnet for the Network Load Balancer"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR range of the Kubernetes VPC"
  type        = string
}

variable "control_plane_instance_id" {
  description = "EC2 instance ID of the Kubernetes control plane"
  type        = string
}

variable "worker1_instance_id" {
  description = "EC2 instance ID of the Kubernetes worker"
  type        = string
}

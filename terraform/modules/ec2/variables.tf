variable "instance_type" {
  description = "EC2 instance type used for Kubernetes nodes"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where Kubernetes nodes will be created"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID attached to Kubernetes nodes"
  type        = string
}

variable "key_name" {
  description = "AWS key pair name used for SSH access"
  type        = string
}


variable "ami_id" {
  description = "Pinned Ubuntu AMI ID used by the existing Kubernetes nodes"
  type        = string
  default     = "ami-0420767433f366d80"
}

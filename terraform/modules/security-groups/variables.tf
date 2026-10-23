variable "vpc_id" {
  description = "ID of the VPC where the security group will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}
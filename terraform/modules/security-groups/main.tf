resource "aws_security_group" "k8s" {
  name        = "multitenant-k8s-sg"
  description = "Security group for kubeadm Kubernetes nodes"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.k8s.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "kubernetes_api" {
  security_group_id = aws_security_group.k8s.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 6443
  to_port           = 6443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "internal" {
  security_group_id            = aws_security_group.k8s.id
  referenced_security_group_id = aws_security_group.k8s.id
  ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.k8s.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

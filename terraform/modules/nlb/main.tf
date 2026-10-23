resource "aws_security_group" "nlb" {
  name        = "multitenant-k8s-nlb-sg"
  description = "Allow public HTTP and HTTPS traffic to the Kubernetes NLB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Public HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Public HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Traefik HTTP NodePort"
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Traefik HTTPS NodePort"
    from_port   = 30443
    to_port     = 30443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "multitenant-k8s-nlb-sg"
  }
}

resource "aws_lb" "k8s" {
  name               = "multitenant-k8s-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [var.subnet_id]
  security_groups    = [aws_security_group.nlb.id]

  tags = {
    Name = "multitenant-k8s-nlb"
  }
}

resource "aws_lb_target_group" "http" {
  name        = "k8s-traefik-http"
  port        = 30080
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    protocol = "TCP"
    port     = "traffic-port"
  }

  tags = {
    Name = "k8s-traefik-http"
  }
}

resource "aws_lb_target_group" "https" {
  name        = "k8s-traefik-https"
  port        = 30443
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    protocol = "TCP"
    port     = "traffic-port"
  }

  tags = {
    Name = "k8s-traefik-https"
  }
}

resource "aws_lb_target_group_attachment" "http_control_plane" {
  target_group_arn = aws_lb_target_group.http.arn
  target_id        = var.control_plane_instance_id
  port             = 30080
}

resource "aws_lb_target_group_attachment" "http_worker1" {
  target_group_arn = aws_lb_target_group.http.arn
  target_id        = var.worker1_instance_id
  port             = 30080
}

resource "aws_lb_target_group_attachment" "https_control_plane" {
  target_group_arn = aws_lb_target_group.https.arn
  target_id        = var.control_plane_instance_id
  port             = 30443
}

resource "aws_lb_target_group_attachment" "https_worker1" {
  target_group_arn = aws_lb_target_group.https.arn
  target_id        = var.worker1_instance_id
  port             = 30443
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.k8s.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.k8s.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https.arn
  }
}

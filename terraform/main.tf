module "vpc" {
  source = "./modules/vpc"

  vpc_cidr           = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
}

module "security_groups" {
  source = "./modules/security-groups"

  vpc_id   = module.vpc.vpc_id
  vpc_cidr = "10.0.0.0/16"
}


module "ec2" {
  source = "./modules/ec2"

  instance_type     = "t3.small"
  subnet_id         = module.vpc.public_subnet_id
  security_group_id = module.security_groups.security_group_id
  key_name          = "multitenant-kubeadm-key"
}
module "nlb" {
  source = "./modules/nlb"

  vpc_id                    = module.vpc.vpc_id
  subnet_id                 = module.vpc.public_subnet_id
  vpc_cidr                  = "10.0.0.0/16"
  control_plane_instance_id = module.ec2.control_plane_instance_id
  worker1_instance_id       = module.ec2.worker1_instance_id
}

resource "aws_vpc_security_group_ingress_rule" "traefik_http_from_nlb" {
  security_group_id            = module.security_groups.security_group_id
  referenced_security_group_id = module.nlb.nlb_security_group_id
  description                  = "Allow HTTP NodePort traffic from the NLB"
  ip_protocol                  = "tcp"
  from_port                    = 30080
  to_port                      = 30080
}

resource "aws_vpc_security_group_ingress_rule" "traefik_https_from_nlb" {
  security_group_id            = module.security_groups.security_group_id
  referenced_security_group_id = module.nlb.nlb_security_group_id
  description                  = "Allow HTTPS NodePort traffic from the NLB"
  ip_protocol                  = "tcp"
  from_port                    = 30443
  to_port                      = 30443
}

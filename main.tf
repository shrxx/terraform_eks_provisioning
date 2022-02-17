provider "aws" {
  region = local.region
}

locals {
  name            = "eks-${var.env_prefix}"
  cluster_version = "1.21"
  region          = "eu-central-1"
}

data "aws_availability_zones" "available_azs" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available_azs.zone_ids
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }
}

resource "aws_security_group" "additional" {
  name_prefix = "${var.env_prefix}-additional-sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name                    = "${var.env_prefix}-eks-cluster"
  cluster_version                 = "1.21"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    node_group = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      create_launch_template = false
      launch_template_name   = ""

      instance_types = var.instance_types
      capacity_type  = "ON_DEMAND"
      remote_access = {
        ec2_ssh_key = var.ec2_ssh_key
      }
    }
  }
}
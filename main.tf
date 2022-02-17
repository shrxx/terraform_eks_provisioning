provider "aws" {
  region = "eu-central-1"
}

data "aws_availability_zones" "available_azs" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${var.env_prefix}-eks"
  cidr = var.vpc_cidr_block

  azs             = data.aws_availability_zones.available_azs.zone_ids
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.env_prefix}-eks-cluster" = "shared"
    "kubernetes.io/role/elb"                              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.env_prefix}-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb"                     = 1
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
      var.vpc_cidr_block
    ]
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name                    = "${var.env_prefix}-eks-cluster"
  cluster_version                 = var.k8s_cluster_version
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
      capacity_type  = var.k8s_worker_capacity_type
      remote_access = {
        ec2_ssh_key = var.ec2_ssh_key
      }
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
module "k8s_deploy" {
  source                     = "./modules/k8s_deploy"
  k8s_cluster_endpoint       = data.aws_eks_cluster.cluster.endpoint
  k8s_cluster_token          = data.aws_eks_cluster_auth.cluster.token
  k8s_cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
}
terraform {
  backend "s3" {
    bucket  = "eks-devops-tf-backend"
    key     = "eks/dev/terraform.tfstate"
    region  = "us-west-2"
    encrypt = true
  }
}

module "vpc" {
  source   = "../../modules/vpc"
  vpc_cidr = var.vpc_cidr
  env      = var.env
}

#############################################
# 👉 USE YOUR CUSTOM EKS MODULE (CORRECT)
#############################################
module "eks" {
  source = "../../modules/eks"

  vpc_id          = module.vpc.vpc_id           # REQUIRED
  private_subnets = module.vpc.private_subnets  # REQUIRED

  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
}


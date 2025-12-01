terraform {
  backend "s3" {
    bucket  = "eks-devops-tf-backendg"
    key     = "eks/dev/terraform.tfstate"
    region  = "us-west-2"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
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

# Note: EKS access policies are used instead of kubernetes_groups to avoid the
# chicken-and-egg RBAC problem. Access policies (AmazonEKSClusterAdminPolicy) are
# managed entirely by AWS and don't require Kubernetes RBAC resources.
# See terraform/modules/eks/main.tf for the access policy configuration.


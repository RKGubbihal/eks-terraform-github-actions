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

# Note: The ClusterRoleBinding for the cluster-admin group must be created manually
# or via a bootstrap script using credentials with admin access to the cluster.
# This is because the IAM user (AIDevOpsUser) cannot create ClusterRoleBindings
# until the binding exists (chicken-and-egg problem).
#
# See scripts/bootstrap-rbac.sh for the bootstrap script.


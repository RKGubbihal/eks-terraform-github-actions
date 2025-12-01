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
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
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

#############################################
# Kubernetes Provider Configuration
#############################################
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name
    ]
  }
}

#############################################
# RBAC Configuration for GitHub Actions
#############################################
resource "kubernetes_cluster_role_binding" "cluster_admin_group_binding" {
  depends_on = [module.eks]

  metadata {
    name = "cluster-admin-group-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "Group"
    name      = "cluster-admin"
    api_group = "rbac.authorization.k8s.io"
  }
}


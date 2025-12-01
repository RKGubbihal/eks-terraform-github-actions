module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.8"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  #############################################
  # PUBLIC ENDPOINT
  #############################################
  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = false
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  #############################################
  # AUTH SETTINGS
  #############################################
  authentication_mode = "API_AND_CONFIG_MAP"

  access_entries = {
    github_actions = {
      principal_arn = "arn:aws:iam::400338099943:user/AIDevOpsUser"
      # Use access policies instead of kubernetes_groups to avoid RBAC chicken-and-egg problem
      # Access policies are AWS-managed and don't require Kubernetes RBAC resources
      # Note: Do not set kubernetes_groups when using access_policy_associations
      access_policy_associations = {
        cluster_admin = {
          policy_arn  = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  #############################################
  # NODE GROUPS
  #############################################
  eks_managed_node_groups = {
    devops_nodes = {
      name            = var.node_group_name
      use_name_prefix = false

      instance_types = ["t4g.medium"]
      ami_type       = "AL2023_ARM_64_STANDARD"

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}


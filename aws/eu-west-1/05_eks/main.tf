################################################################################
# EKS Module
################################################################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                    = local.name_prefix
  cluster_version                 = local.cluster_version
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # IPV4
  cluster_ip_family = "ipv4"

  create_cni_ipv6_iam_policy = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent              = true
      before_compute           = true
      service_account_role_arn = module.vpc_cni_irsa_role.iam_role_arn
      configuration_values     = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
  }

  vpc_id                   = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids               = data.terraform_remote_state.vpc.outputs.private_subnets
  control_plane_subnet_ids = data.terraform_remote_state.vpc.outputs.intra_subnets

  eks_managed_node_group_defaults = {
    ami_type                   = var.ami_type
    instance_types             = [var.instance_types]
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    # Default node group - as provided by AWS EKS
    tf_default_node_group = {
      use_custom_launch_template = false
      min_size                   = var.eks_min_size
      max_size                   = var.eks_max_size
      desired_size               = var.eks_desired_size

      disk_size = var.eks_nodes_disk_size


      tags = merge(local.default_tags, {
        Name = "tf-datasquad-eks-default-node-group"
      })
    }
  }

  tags = merge(local.default_tags, {
    Name = local.name_prefix
  })
  enable_cluster_creator_admin_permissions = true
}

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
      configuration_values = jsonencode({
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

  iam_role_additional_policies = {
    additional = aws_iam_policy.node_additional.arn
    ecr        = aws_iam_policy.additional_ecr_access.arn
    #ebs        = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }
  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
    # Test: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/2319
    ingress_source_security_group_id = {
      description              = "Ingress from another computed security group"
      protocol                 = "tcp"
      from_port                = 22
      to_port                  = 22
      type                     = "ingress"
      source_security_group_id = aws_security_group.eks_additional.id
    }
  }

  eks_managed_node_group_defaults = {
    ami_type                   = var.ami_type
    instance_types             = [var.instance_types]
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    # Default node group - as provided by AWS EKS
    tf_default_node_group = {
      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      use_custom_launch_template = false
      min_size                   = var.eks_min_size
      max_size                   = var.eks_max_size
      desired_size               = var.eks_desired_size

      disk_size = var.eks_nodes_disk_size

      # Remote access cannot be specified with a launch template
      remote_access = {
        ec2_ssh_key               = module.key_pair.key_pair_name
        source_security_group_ids = [aws_security_group.remote_access.id]
        tags                      = local.default_tags
      }
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
      tags = merge(local.default_tags, {
        Name                 = "tf_eks_default_node_group"
      })
    }
  }

  tags = merge(local.default_tags, {
    Name                 = local.name_prefix
  })
  enable_cluster_creator_admin_permissions = true
  access_entries = {
    cluster_creator = {
      principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/terraform"
      type          = "STANDARD"

      policy_associations = {
        admin = {
          policy_arn = "arn:${local.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    },
    cluster_user = {
      principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/malaa"
      type          = "STANDARD"

      policy_associations = {
        admin = {
          policy_arn = "arn:${local.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}

################################################################################
# EKS Module
################################################################################
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                    = local.name_prefix
  cluster_version                 = local.cluster_version
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true


  # IPV4
  cluster_ip_family          = "ipv4"
  create_cni_ipv6_iam_policy = true

  enable_cluster_creator_admin_permissions = true

  # Enable EFA support by adding necessary security group rules
  # to the shared node security group

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent          = true
      before_compute       = true
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    ### aws-ebs-csi-driver
  }

  vpc_id                   = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids               = data.terraform_remote_state.vpc.outputs.private_subnets
  control_plane_subnet_ids = data.terraform_remote_state.vpc.outputs.intra_subnets

  ## additional iam policy

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_ARM_64"
    instance_types = ["t4g.medium"]
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    # Default node group - as provided by AWS EKS
    tf_default_node_group = {
      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      use_custom_launch_template = false

      disk_size                    = 50
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }

      min_size     = 1
      max_size     = 3
      desired_size = 2
      tags = merge(local.default_tags, {
        Name = "tf_eks_default_node_group"
      })
    }

    #  access_entries = {
    #    # One access entry with a policy associated
    #    ex-single = {
    #      kubernetes_groups = []
    #      principal_arn     = aws_iam_role.this["single"].arn
    #
    #      policy_associations = {
    #        single = {
    #          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
    #          access_scope = {
    #            namespaces = ["default"]
    #            type       = "namespace"
    #          }
    #        }
    #      }
    #    }
    #
    #    # Example of adding multiple policies to a single access entry
    #    ex-multiple = {
    #      kubernetes_groups = []
    #      principal_arn     = aws_iam_role.this["multiple"].arn
    #
    #      policy_associations = {
    #        ex-one = {
    #          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
    #          access_scope = {
    #            namespaces = ["default"]
    #            type       = "namespace"
    #          }
    #        }
    #        ex-two = {
    #          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
    #          access_scope = {
    #            type = "cluster"
    #          }
    #        }
    #      }
    #    }
    #  }

    tags = local.default_tags
  }

}
module "ebs_kms_key" {
  source      = "terraform-aws-modules/kms/aws"
  version     = "~> 1.5"
  description = "Customer managed key to encrypt EKS managed node group volumes"

  # Policy
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  key_service_roles_for_autoscaling = [
    # required for the ASG to manage encrypted volumes for nodes
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
    # required for the cluster / persistentvolume-controller to create encrypted PVCs
    module.eks.cluster_iam_role_arn,
  ]

  # Aliases
  aliases = ["eks/${var.name}-eks/ebs"]

  tags = merge(local.default_tags, {
    Name                 = "${local.name_prefix}-ebs-kms-key"
    yor_trace            = "446a1699-6bbe-40fc-be93-0071600bd32f"
    Env                  = "Prod"
    git_last_modified_by = "malaa"
    git_modifiers        = "MoustafaAMahmoud"
    git_org              = "datasquadapp.ai"
    git_commit           = "903a451eea0a98ae6c22950b4ac2f18d2be0c5aa"
    git_file             = "eu-west-1/03_eks/kms.tf"
    git_last_modified_at = "2024-01-28 11:45:05"
    git_repo             = "datasquad-infra"
    yor_name             = "ebs_kms_key"
  })
}

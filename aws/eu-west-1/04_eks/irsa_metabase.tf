#---------------------------------------------------------------
# Metabase Namespace
#---------------------------------------------------------------
#resource "kubernetes_namespace_v1" "metabase" {
#  metadata {
#    name = "metabase"
#  }
#  timeouts {
#    delete = "15m"
#  }
#}
#---------------------------------------------------------------
# IRSA module for Metabase
#---------------------------------------------------------------

module "external_metabase_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${local.name_prefix}-metabase-irsa"

  attach_external_secrets_policy                     = true
  external_secrets_ssm_parameter_arns                = ["arn:aws:ssm:*:*:parameter/${local.name_prefix}-*"]
  external_secrets_secrets_manager_arns              = ["arn:aws:secretsmanager:*:*:secret:${local.name_prefix}-*"]
  external_secrets_secrets_manager_create_permission = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["metabase:tf-datasquad-eks-metabase-irsa"]
      #      namespace_service_accounts = ["${kubernetes_namespace_v1.metabase.metadata[0].name}:tf-datasquad-eks-metabase-irsa"]
    }
  }


  tags = merge(local.default_tags, {
    Name                 = "${local.name_prefix}-airflow-irsa"
    git_file             = "eu-west-1/03_eks/irsa.tf"
    git_modifiers        = "MoustafaAMahmoud"
    git_org              = "datasquadapp.ai"
    git_repo             = "datasquad-infra"
    yor_name             = "external_metabase_irsa_role"
    git_last_modified_by = "malaa"
  })
}

resource "kubernetes_service_account_v1" "metabase-sa" {
  metadata {
    name = module.external_metabase_irsa_role.iam_role_name
    #    namespace   = kubernetes_namespace_v1.metabase.metadata[0].name
    namespace   = "metabase"
    annotations = { "eks.amazonaws.com/role-arn" : module.external_metabase_irsa_role.iam_role_arn }
  }

  automount_service_account_token = true
}
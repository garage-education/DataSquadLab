module "external_secrets_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${local.name_prefix}-external-secrets-irsa"

  attach_external_secrets_policy                     = true
  external_secrets_ssm_parameter_arns                = ["arn:aws:ssm:*:*:parameter/${local.name_prefix}-*"]
  external_secrets_secrets_manager_arns              = ["arn:aws:secretsmanager:*:*:secret:${local.name_prefix}-*", "arn:aws:secretsmanager:*:*:secret:tf-s3-prod-eu-west-1-app-backend-db-*"]
  external_secrets_secrets_manager_create_permission = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["datasquad-production:datasquad-api-external-secret-sa"]
    }
  }


  tags = merge(local.default_tags, {
    Name                 = "${local.name_prefix}-external-secrets-irsa"
    yor_name             = "external_secrets_irsa_role"
    yor_trace            = "29f14fd6-59de-4058-8649-bdb2b6580a4c"
    git_last_modified_by = "malaa"
  })
}

#---------------------------------------------------------------
# datasquad Backoffice Namespace
#---------------------------------------------------------------
resource "kubernetes_namespace_v1" "datasquad_backoffice" {
  metadata {
    name = local.backoffice_namespace_name
  }
  timeouts {
    delete = "15m"
  }
}

module "datasquad_backoffice_receipts_irsa_role" {
  depends_on = [kubernetes_namespace_v1.datasquad_backoffice]
  source     = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version    = "~> 5.0"

  role_name = "${local.name_prefix}-backoffice-receipt-irsa"

  attach_external_secrets_policy                     = true
  external_secrets_secrets_manager_arns              = ["arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${local.name_prefix}-receipt-*"]
  external_secrets_secrets_manager_create_permission = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${kubernetes_namespace_v1.datasquad_backoffice.metadata[0].name}:datasquad-receipts-backoffice-sa"]
    }
  }

  tags = merge(local.default_tags, {
    Name     = "${local.name_prefix}-backoffice-receipt-irsa"
    yor_name = "datasquad_backoffice_receipt_irsa_role"

  })
}
#
resource "kubernetes_service_account_v1" "backoffice-sa" {
  depends_on = [kubernetes_namespace_v1.datasquad_backoffice, module.datasquad_backoffice_receipts_irsa_role]
  metadata {
    name        = "datasquad-receipts-backoffice-sa"
    namespace   = kubernetes_namespace_v1.datasquad_backoffice.metadata[0].name
    annotations = { "eks.amazonaws.com/role-arn" : module.datasquad_backoffice_receipts_irsa_role.iam_role_arn }
  }

  automount_service_account_token = true
}
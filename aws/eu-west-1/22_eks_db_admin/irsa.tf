locals {
  aws_iam_irsa_postfix_name                     = "external-secret-irsa"
  aws_iam_irsa_role_name                        = "${local.name_prefix}-${local.secret_name}-${local.aws_iam_irsa_postfix_name}"
}
module "rds_admin_external_secret_irsa_role" {
  source             = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version            = "~> 5.0"
  role_name          = local.aws_iam_irsa_role_name
  policy_name_prefix = "${local.name_prefix}-rds-admin-"

  attach_external_secrets_policy      = true
  external_secrets_ssm_parameter_arns = [
    "arn:aws:ssm:${var.region}:${local.env.account_id}:parameter/${local.name_prefix}-*"
  ]
  external_secrets_secrets_manager_arns = [
    "arn:aws:secretsmanager:${var.region}:${local.env.account_id}:secret:*db*"
  ]
  oidc_providers = {
    ex = {
      provider_arn               = data.terraform_remote_state.eks.outputs.oidc_provider_arn
      namespace_service_accounts = ["${local.k8s_db_namespace_name}:${local.k8s_db_rds_admin_service_account_name}"]
    }
  }

  tags = merge(local.default_tags,
    {
      Name = local.aws_iam_irsa_role_name
    })
}
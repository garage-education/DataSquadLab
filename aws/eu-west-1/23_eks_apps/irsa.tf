module "petclinic_app_external_secret_irsa" {
  source                                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version                               = "~> 5.0"
  role_name                             = "${local.name_prefix}-${local.k8s_petclinic_app_namespace}-app-irsa"
  attach_external_secrets_policy        = true
  external_secrets_secrets_manager_arns = [
    "arn:aws:secretsmanager:${var.region}:${local.env.account_id}:secret:${local.aws_rds_db_admin_secret_name}"
  ]
  policy_name_prefix = "${local.name_prefix}-${local.k8s_petclinic_app_namespace}-app-"

  oidc_providers = {
    ex = {
      provider_arn               = data.terraform_remote_state.eks.outputs.oidc_provider_arn
      namespace_service_accounts = ["${local.k8s_petclinic_app_namespace}:${local.k8s_petclinic_app_service_account_name}"]
    }
  }

  tags = merge(local.default_tags,
    {
      Name = "${local.name_prefix}-${local.k8s_petclinic_app_namespace}-app-irsa"
    })
}
module "petclinic_app_external_secret_irsa" {
  source                                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version                               = "~> 5.0"
  role_name                             = "${local.name_prefix}-petclinic-app-irsa"
  attach_external_secrets_policy        = true
  external_secrets_secrets_manager_arns = [
    "arn:aws:secretsmanager:${var.region}:${local.env.account_id}:secret:tf-petclinic-db-secret*"
  ]
  policy_name_prefix = "${local.name_prefix}-petclinic-app-"

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["petclinic:petclinic-app-external-secret-sa"]
    }
  }

  tags = merge(local.default_tags,
    {
      Name = "${local.name_prefix}-petclinic-app-irsa"
    })
}

module "rds_admin_external_secret_irsa_role" {
  source             = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version            = "~> 5.0"
  role_name          = "${local.name_prefix}-rds-admin-irsa"
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
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["db:rds-admin-external-secret-sa"]
    }
  }

  tags = merge(local.default_tags,
    {
      Name = "${local.name_prefix}-petclinic-app-irsa"
    })
}


module "metabase_app_external_secret_irsa" {
  source                                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version                               = "~> 5.0"
  role_name                             = "${local.name_prefix}-metabase-app-irsa"
  attach_external_secrets_policy        = true
  external_secrets_secrets_manager_arns = [
    "arn:aws:secretsmanager:${var.region}:${local.env.account_id}:secret:tf-metabase-db-secret*"
  ]
  policy_name_prefix = "${local.name_prefix}-metabase-app-"

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["metabase:tf-datasquad-eks-metabase-sa"]
    }
  }

  tags = merge(local.default_tags,
    {
      Name = "${local.name_prefix}-metabase-app-irsa"
    })
}
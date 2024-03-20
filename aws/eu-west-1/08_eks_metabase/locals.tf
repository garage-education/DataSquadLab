locals {
  name_prefix                       = "${var.prefix}${var.name}-eks"
  k8s_metabase_namespace            = "metabase"
  k8s_metabase_service_account_name = "${local.name_prefix}-${local.k8s_metabase_namespace}-external-secret-sa"

  env                               = {
    account_id  = data.aws_caller_identity.current.account_id
    region      = data.aws_region.current.name
    environment = var.environment
  }

  default_tags = {
    Region      = data.aws_region.current.name
    Environment = var.environment
    Owner       = "INFRA_TEAM"
    Project     = "INFRA_PROJECT"
    Stage       = "KUBERNETES"
    ManagedBy   = var.ManagedBy
    CostCenter  = "APP"
  }
}

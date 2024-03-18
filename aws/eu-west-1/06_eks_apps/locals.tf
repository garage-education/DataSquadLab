locals {
  name_prefix                       = "${var.prefix}${var.name}-eks"
  rds_external_admin_db_secret_name = "${local.name_prefix}-rds-admin-external-secret"
  metabase_external_secret_name     = "${local.name_prefix}-metabase-external-secret"
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


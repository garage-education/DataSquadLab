locals {
  name_prefix                       = "${var.prefix}${var.name}-eks"
  rds_external_admin_db_secret_name = "${local.name_prefix}-rds-admin-external-secret"
  metabase_external_secret_name     = "${local.name_prefix}-metabase-external-secret"

  db_namespace_name                             = "db"
  db_service_account_name                       = "rds-admin-external-secret-sa"
  db_external_secret_store_name                 = "tf-datasquad-rds-db-store"
  rds_db_admin_aws_external_secret_name         = "tf-rds-db-admin-secret"
  rds_db_admin_managed_aws_external_secret_name = "rds!db-390eb28a-2563-4d84-b9f1-9b3205f59365"
  rds_k8s_external_admin_db_secret_name         = "${local.name_prefix}-rds-admin-external-secret"

  k8s_property_key_external_secret_db_user     = "database_user"
  k8s_property_key_external_secret_db_password = "database_password"
  k8s_property_key_external_secret_db_name     = "database_name"

  env = {
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

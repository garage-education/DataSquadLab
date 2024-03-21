locals {
  name_prefix = "${var.prefix}${var.name}-eks"

  secret_name                      = "rds-admin"
  k8s_service_account_postfix_name = "external-secret-sa"

  k8s_db_namespace_name                       = "db"
  k8s_db_rds_admin_external_secret_store_name = "${local.k8s_db_namespace_name}-${local.secret_name}-secret-store"
  k8s_db_rds_admin_service_account_name       = "${local.k8s_db_namespace_name}-${local.secret_name}-${local.k8s_service_account_postfix_name}"
  k8s_db_rds_admin_external_secret_name       = "${local.name_prefix}-${local.secret_name}-external-secret"


  #Below could be merged into one secret
  aws_rds_db_admin_external_secret_name         = "tf-rds-db-admin-secret" #TODO: to be automated
  aws_rds_db_admin_managed_external_secret_name = "rds!db-390eb28a-2563-4d84-b9f1-9b3205f59365"#TODO: to be automated

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

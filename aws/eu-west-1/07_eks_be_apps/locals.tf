locals {
  name_prefix = "${var.prefix}${var.name}-eks"

  k8s_service_account_postfix_name           = "external-secret-sa"
  k8s_petclinic_app_namespace            = "petclinic"
  k8s_petclinic_app_service_account_name = "${local.k8s_petclinic_app_namespace}-app-${local.k8s_service_account_postfix_name}"
  aws_rds_db_admin_secret_name           = "tf-petclinic-db-secret*"

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

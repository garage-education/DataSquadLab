################################################################################
# Tags for the ASG to support cluster-autoscaler scale up from 0
################################################################################

locals {

  name_prefix                = "${var.prefix}${var.name}-app-db"
  name_prefix_subnet_group   = "${local.name_prefix}-subnet-group"
  name_prefix_db_group       = "${local.name_prefix}-param-group"
  name_prefix_secret_name    = "${local.name_prefix}-secret"
  name_prefix_security_group = "${local.name_prefix}-sg"
  name_prefix_iam_role       = "${local.name_prefix}-role"

  env = {
    account_id  = data.aws_caller_identity.current.account_id
    region      = data.aws_region.current.name
    environment = var.environment
  }

  default_tags = {
    Region      = data.aws_region.current.name
    Environment = var.environment
    Owner       = "APP_TEAM"
    Project     = "datasquad_APP"
    Stage       = "APP_BACKEND"
    ManagedBy   = var.ManagedBy
    CostCenter  = "datasquad_APP"
    Repository  = "https://github.com/terraform-aws-modules/terraform-aws-rds"
  }


}

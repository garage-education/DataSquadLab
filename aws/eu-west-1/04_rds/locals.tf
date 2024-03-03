locals {
  name_prefix = "${var.prefix}${var.name}-app-db"
  name_prefix_subnet_group   = "${local.name_prefix}-subnet-group"
  name_prefix_security_group = "${local.name_prefix}-sg"
  name_prefix_kms = "${local.name_prefix}-kms-key"
  env = {
    account_id  = data.aws_caller_identity.current.account_id
    region      = data.aws_region.current.name
    environment = var.environment
  }

  default_tags = {
    Region      = data.aws_region.current.name
    Environment = var.environment
    Owner       = "APP_TEAM"
    Project     = "APP_BACKEND"
    Stage       = "APP_BACKEND"
    ManagedBy   = var.ManagedBy
    CostCenter  = "APP"
  }
}


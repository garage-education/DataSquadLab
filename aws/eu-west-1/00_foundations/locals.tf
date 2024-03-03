locals {
  name_prefix = "${var.prefix}${var.name}-infra"

  env = {
    account_id  = data.aws_caller_identity.current.account_id
    region      = data.aws_region.current.name
    environment = var.environment
  }

  default_tags = {
    Region      = data.aws_region.current.name
    Environment = var.environment
    Owner       = "APP_TEAM"
    Project     = "DATASQUAD_INFRA"
    Stage       = "NETWORK"
    ManagedBy   = var.ManagedBy
    CostCenter  = "GENERAL"
  }
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}


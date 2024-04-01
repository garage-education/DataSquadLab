locals {
  current_identity = data.aws_caller_identity.current.arn

  env = {
    account_id  = data.aws_caller_identity.current.account_id
    region      = data.aws_region.current.name
    environment = var.environment
  }

  default_tags = {
    Region      = data.aws_region.current.name
    Environment = var.environment
    Owner       = "DATA_TEAM"
    Project     = "DATA_LAKE"
    Stage       = "DATA_LAKE"
    ManagedBy   = var.ManagedBy
    CostCenter  = "DATALAKE"
  }
}


################################################################################
# Tags for the ASG to support cluster-autoscaler scale up from 0
################################################################################

locals {
  name_prefix = "${var.prefix}${var.name}-github"

  env = {
    account_id  = data.aws_caller_identity.current.account_id
    region      = data.aws_region.current.name
    environment = var.environment
  }

  default_tags = {
    Region      = data.aws_region.current.name
    Environment = var.environment
    Owner       = var.owner
    Project     = "datasquad_APP"
    Stage       = "CICD"
    ManagedBy   = var.ManagedBy
    CostCenter  = "datasquad_APP"
  }
}

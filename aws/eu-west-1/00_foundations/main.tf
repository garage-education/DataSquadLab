################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"


  name = local.name_prefix
  cidr = var.vpc_cidr

  azs                 = local.azs
  private_subnets     = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets      = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 51)]
  intra_subnets       = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 101)]

  enable_nat_gateway = true
  single_nat_gateway = true

  create_egress_only_igw =true


  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  tags = local.default_tags
}

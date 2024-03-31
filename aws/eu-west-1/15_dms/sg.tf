module "dms_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  # Creates multiple
  for_each = {
    postgresql-source    = ["postgresql-tcp"]
  }

  name        = "${local.name_prefix}-${each.key}"
  description = "Security group for ${each.key}"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  ingress_rules       = each.value

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = local.default_tags
}

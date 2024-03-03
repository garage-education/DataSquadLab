#############################################################
############# Secrets DB ####################################
#############################################################
## SM secret in production:
## rds_mysql/elmenus/dms_replication
data "aws_secretsmanager_secret" "dms_source_secret_rds_psql_prod" {
  arn = "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${data.terraform_remote_state.sm.outputs.datasquad_app_backend_db_secret_name}"
}

data "aws_secretsmanager_secret_version" "rds_secret_prod_psql_current" {
  secret_id     = data.aws_secretsmanager_secret.dms_source_secret_rds_psql_prod.id
  version_stage = "AWSCURRENT"
}
#############################################################
resource "aws_db_parameter_group" "pg_db_group" {
  name   = local.name_prefix_db_group
  family = "postgres14"

  parameter {
    name         = "log_connections"
    value        = "1"
    apply_method = "pending-reboot"
  }
  parameter {
    name         = "rds.logical_replication"
    value        = "1"
    apply_method = "pending-reboot"
  }


  lifecycle {
    create_before_destroy = true
  }
  tags = merge(local.default_tags,{
    Name = "${local.name_prefix}-pg-db-group"
  }
  )
}
################################################################################
# RDS Security Group
################################################################################
module "datasquad_app_rds_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = local.name_prefix_security_group
  description = "datasquadApp RDS PostgreSQL security group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
    },
  ]
  tags = merge(local.default_tags, {
    Name = "${local.name_prefix}-datasquad-app-rds-security-group"
  })
}
################################################################################
# RDS Module
################################################################################
module "datasquad_be_app_rds_db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = local.name_prefix

  instance_use_identifier_prefix = false

  create_db_option_group    = false
  create_db_parameter_group = false
  parameter_group_name      = aws_db_parameter_group.pg_db_group.name

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine                       = jsondecode(data.aws_secretsmanager_secret_version.rds_secret_prod_psql_current.secret_string)["engine"]
  engine_version               = "14"
  family                       = "postgres14" # DB parameter group
  major_engine_version         = "14"         # DB option group
  instance_class               = "db.t3.micro"
  max_allocated_storage        = 1000
  allocated_storage            = 20
  storage_encrypted            = true
  kms_key_id                   = module.datasquad_app_db_kms.key_arn
  performance_insights_enabled = true

  # NOTE: Do NOT use 'user' as the value for 'username' or 'admin' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name  = jsondecode(data.aws_secretsmanager_secret_version.rds_secret_prod_psql_current.secret_string)["dbname"]
  username = jsondecode(data.aws_secretsmanager_secret_version.rds_secret_prod_psql_current.secret_string)["username"]
  port     = jsondecode(data.aws_secretsmanager_secret_version.rds_secret_prod_psql_current.secret_string)["port"]
  password = jsondecode(data.aws_secretsmanager_secret_version.rds_secret_prod_psql_current.secret_string)["password"]




  # Enable creation of subnet group (disabled by default)
  create_db_subnet_group      = true
  db_subnet_group_name        = local.name_prefix_subnet_group
  db_subnet_group_description = local.name_prefix_subnet_group
  db_subnet_group_tags        = local.default_tags
  subnet_ids                  = data.terraform_remote_state.vpc.outputs.private_subnets
  vpc_security_group_ids      = [module.datasquad_app_rds_security_group.security_group_id]

  # Enable creation of monitoring IAM role
  create_monitoring_role = true
  monitoring_interval    = "30"
  monitoring_role_name   = local.name_prefix_iam_role


  maintenance_window          = "fri:02:30-fri:03:30"
  backup_window               = "04:00-07:00"
  backup_retention_period     = 0
  manage_master_user_password = false
  # Database Deletion Protection
  #deletion_protection = true
  tags = local.default_tags
}

module "datasquad_app_db_kms" {
  source      = "terraform-aws-modules/kms/aws"
  version     = "~> 1.0"
  description = "KMS key for datasquad db encrypted storage"

  # Aliases
  aliases                 = [local.name_prefix]
  aliases_use_name_prefix = true

  key_owners = [data.aws_caller_identity.current.arn]

  tags = merge(local.default_tags, {
    Name = "${local.name_prefix}-datasquad-app-db-kms"
  })
}

################################################################################
# RDS Module
################################################################################
module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = local.name_prefix
  instance_use_identifier_prefix = false

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "14"
  family               = "postgres14" # DB parameter group
  major_engine_version = "14"         # DB option group
  instance_class       = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name  = "pet_clinic"
  username = "louisa"
  port     = 5432

  # setting manage_master_user_password_rotation to false after it
  # has been set to true previously disables automatic rotation
  manage_master_user_password_rotation              = true
  master_user_password_rotate_immediately           = false
  master_user_password_rotation_schedule_expression = "rate(30 days)"

  multi_az               = false

  create_db_subnet_group      = true
  db_subnet_group_name        = local.name_prefix_subnet_group
  db_subnet_group_description = local.name_prefix_subnet_group
  db_subnet_group_tags        = local.default_tags
  subnet_ids                  = data.terraform_remote_state.vpc.outputs.private_subnets


  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window              = "fri:03:30-fri:06:00"
  backup_window                   = "00:30-02:30"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "${local.name_prefix}-role"
  monitoring_role_use_name_prefix       = true
  monitoring_role_description           = "Description for monitoring role"
  kms_key_id = module.kms.key_arn
  tags = local.default_tags

}

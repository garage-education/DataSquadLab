data "aws_secretsmanager_secret" "dms_source_secret_rds_psql_prod" {
  arn = data.terraform_remote_state.rds.outputs.db_instance_master_user_secret_arn
}

data "aws_secretsmanager_secret_version" "rds_secret_prod_psql_current" {
  secret_id     = data.aws_secretsmanager_secret.dms_source_secret_rds_psql_prod.id
  version_stage = "AWSCURRENT"
}

module "dms_replication_instance" {
  source = "terraform-aws-modules/dms/aws"

  # Subnet group
  repl_subnet_group_name        = local.name_prefix
  repl_subnet_group_description = "DMS Subnet group for ${local.name_prefix}"
  repl_subnet_group_subnet_ids  = data.terraform_remote_state.vpc.outputs.private_subnets

  # Instance
  repl_instance_allocated_storage            = 64
  repl_instance_auto_minor_version_upgrade   = true
  repl_instance_allow_major_version_upgrade  = false
  repl_instance_apply_immediately            = true
  repl_instance_engine_version               = "3.5.2"
  repl_instance_multi_az                     = true
  repl_instance_preferred_maintenance_window = "fri:02:30-fri:03:30"
  repl_instance_publicly_accessible          = false
  repl_instance_class                        = "dms.t3.small"
  repl_instance_id                           = local.name_prefix
  repl_instance_vpc_security_group_ids       = [module.dms_security_group["postgresql-source"].security_group_id]
  repl_instance_kms_key_arn                  = module.db_kms.key_arn


  # Access role
  access_kms_key_arns = [module.db_kms.key_arn]

  create_access_iam_role = true
  access_secret_arns     = [
    data.terraform_remote_state.rds.outputs.db_instance_master_user_secret_arn
  ]

  access_target_s3_bucket_arns = [
    data.terraform_remote_state.s3.outputs.s3_landing_zone_bucket_arn,
    "${data.terraform_remote_state.s3.outputs.s3_landing_zone_bucket_arn}/*"
  ]
  #
  # S3 Endpoints
  s3_endpoints = {
    s3-target-cdc = {
      endpoint_id   = "${local.name_prefix}-s3-target"
      endpoint_type = "target"
      engine_name   = "s3"

      bucket_folder = "${var.environment}/rds-psql/full_load"

      bucket_name                 = data.terraform_remote_state.s3.outputs.s3_landing_zone_bucket_id
      data_format                 = "parquet"
      ssl_mode                    = "none"
      encryption_mode             = "SSE_S3" #SSE_KMS
      #      ServerSideEncryptionKmsKeyId
      extra_connection_attributes = ""
      add_column_name             = "true"
      compression_type            = "GZIP"
      date_partition_delimiter    = "SLASH"
      date_partition_enabled      = "true"
      timestamp_column_name       = "dms_ts"
      include_op_for_full_load    = "true"
      cdc_min_file_size           = "32"
      enable_statistics           = true
      extra_connection_attributes = ""
      cdc_path                    = "${var.environment}/rds-psql/cdc/"
      #      service_access_role_arn     = aws_iam_role.dms_access_for_s3_endpoint.arn

      #      external_table_definition = file("configs/s3_table_definition.json")
      tags = { EndpointType = "s3-cdc-target" }
    }
  }

  # Endpoints
  endpoints = {
    postgresql-source = {
      database_name     = data.terraform_remote_state.rds.outputs.db_instance_name
      endpoint_id       = "${local.name_prefix}-${data.terraform_remote_state.rds.outputs.db_instance_engine}-source"
      endpoint_type     = "source"
      engine_name       = data.terraform_remote_state.rds.outputs.db_instance_engine
      username          = jsondecode(data.aws_secretsmanager_secret_version.rds_secret_prod_psql_current.secret_string)["username"]
      password          = jsondecode(data.aws_secretsmanager_secret_version.rds_secret_prod_psql_current.secret_string)["password"]
      server_name       = data.terraform_remote_state.rds.outputs.db_instance_address
      port              = data.terraform_remote_state.rds.outputs.db_instance_port
      postgres_settings = {
        capture_ddls        = false
        heartbeat_enable    = true
        heartbeat_frequency = 1
      }

      tags = { EndpointType = "postgresql-source" }
    }
  }

  replication_tasks = {

    postgresql_s3_cdc = {
      replication_task_id       = "${local.name_prefix}-postgres-to-s3-cdc"
      migration_type            = "full-load-and-cdc"
      replication_task_settings = file("config/task_settings.json")
      table_mappings            = file("config/table_mappings.json")
      source_endpoint_key       = "postgresql-source"
      target_endpoint_key       = "s3-target-cdc"
      tags                      = merge({ Task = "Postgres-cdc-S3", }, local.default_tags)
    }

  }

  tags = local.default_tags
}
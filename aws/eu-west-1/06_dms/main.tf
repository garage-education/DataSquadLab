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

# DMS Endpoint
resource "aws_iam_role" "dms_access_for_s3_endpoint" {
  name_prefix = "${local.name_prefix}-s3-endpoint-role"
  description = "DMS IAM role for s3 endpoint access permissions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "dms.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = "s3fullaccess"
      },
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3FullAccess"]
  tags                = local.default_tags
}

#############################################################
############# DMS        ####################################
#############################################################
module "dms_rds_migration" {
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
  repl_instance_multi_az                     = false
  repl_instance_preferred_maintenance_window = "fri:02:30-fri:03:30"
  repl_instance_publicly_accessible          = false
  repl_instance_class                        = "dms.t3.small"
  repl_instance_id                           = local.name_prefix
  repl_instance_vpc_security_group_ids       = [module.security_group["replication-instance"].security_group_id]

  # Access role
  create_access_iam_role = true
  access_secret_arns = [
    data.terraform_remote_state.sm.outputs.datasquad_app_backend_db_secret_arn
  ]
  access_source_s3_bucket_arns = [
    data.terraform_remote_state.s3.outputs.s3_landing_zone_bucket_arn,
    "${data.terraform_remote_state.s3.outputs.s3_landing_zone_bucket_arn}/*"
  ]

  #  # S3 Endpoints
  s3_endpoints = {
    s3-target-cdc = {
      endpoint_id   = "${local.name_prefix}-s3-cdc-target"
      endpoint_type = "target"
      engine_name   = "s3"

      bucket_folder   = "rds-psql/prod"
      bucket_name     = data.terraform_remote_state.s3.outputs.s3_landing_zone_bucket_id
      data_format     = "parquet"
      ssl_mode        = "none"
      encryption_mode = "SSE_S3"

      add_column_name             = "true"
      compression_type            = "GZIP"
      date_partition_delimiter    = "SLASH"
      date_partition_enabled      = "true"
      timestamp_column_name       = "dms_ts"
      include_op_for_full_load    = "true"
      cdc_min_file_size           = "32"
      enable_statistics           = true
      extra_connection_attributes = ""
      service_access_role_arn     = aws_iam_role.dms_access_for_s3_endpoint.arn
      #      external_table_definition   = file("configs/s3_table_definition.json")
      tags = merge({ EndpointType = "s3-cdc-target", }, local.default_tags)
    }
    s3-target-full-load = {
      endpoint_id   = "${local.name_prefix}-s3-full-load-target"
      endpoint_type = "target"
      engine_name   = "s3"

      bucket_folder   = "rds-psql/full-load"
      bucket_name     = data.terraform_remote_state.s3.outputs.s3_landing_zone_bucket_id
      data_format     = "parquet"
      ssl_mode        = "none"
      encryption_mode = "SSE_S3"

      add_column_name             = "true"
      compression_type            = "GZIP"
      timestamp_column_name       = "dms_ts"
      include_op_for_full_load    = "true"
      cdc_min_file_size           = "32"
      enable_statistics           = true
      service_access_role_arn     = aws_iam_role.dms_access_for_s3_endpoint.arn
      extra_connection_attributes = ""
      #      external_table_definition   = file("configs/s3_table_definition.json")
      tags = merge({ EndpointType = "s3-full-load-target", }, local.default_tags)
    }
  }

  # Endpoints
  endpoints = {
    postgresql-source = {
      endpoint_id         = "${local.name_prefix}-datasquad-app-psql-source"
      endpoint_type       = "source"
      engine_name         = jsondecode(data.aws_secretsmanager_secret_version.rds_secret_prod_psql_current.secret_string)["engine"]
      secrets_manager_arn = data.terraform_remote_state.sm.outputs.datasquad_app_backend_db_secret_arn
      postgres_settings = {
        capture_ddls        = true
        heartbeat_enable    = true
        heartbeat_frequency = 1
      }
      tags = { EndpointType = "postgresql-source" }
    }
  }

  replication_tasks = {
    postgresql_cdc = {
      replication_task_id       = "${local.name_prefix}-postgres-to-s3-cdc"
      migration_type            = "cdc"
      replication_task_settings = file("configs/task_settings.json")
      table_mappings            = file("configs/table_mappings.json")
      source_endpoint_key       = "postgresql-source"
      target_endpoint_key       = "s3-target-cdc"
      tags                      = merge({ Task = "Postgres-cdc-S3", }, local.default_tags)
    }
    postgresql_full_load = {
      replication_task_id       = "${local.name_prefix}-postgres-to-s3-fullload"
      migration_type            = "full-load"
      replication_task_settings = file("configs/task_settings.json")
      table_mappings            = file("configs/table_mappings.json")
      source_endpoint_key       = "postgresql-source"
      target_endpoint_key       = "s3-target-full-load"
      tags                      = merge({ Task = "Postgres-full-load-S3", }, local.default_tags)
    }
  }


  tags = local.default_tags
}
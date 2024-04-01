module "airflow_log_bucket" {
  source                  = "terraform-aws-modules/s3-bucket/aws"
  acceleration_status     = "Suspended"
  bucket                  = "${local.name_prefix}-airflow-logs"
  # S3 bucket-level Public Access Block configuration (by default now AWS has made this default as true for S3 bucket-level block public access)
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  expected_bucket_owner = data.aws_caller_identity.current.account_id

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = data.terraform_remote_state.kms.outputs.data_kms_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = local.default_tags
}

module "landing_zone_bucket" {
  source              = "terraform-aws-modules/s3-bucket/aws"
  acceleration_status = "Suspended"
  bucket              = "${local.name_prefix}-lz"

  # S3 bucket-level Public Access Block configuration
  block_public_acls                    = true
  block_public_policy                  = true
  ignore_public_acls                   = true
  restrict_public_buckets              = true
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = data.terraform_remote_state.kms.outputs.data_kms_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  expected_bucket_owner = data.aws_caller_identity.current.account_id
  tags                  = local.default_tags
}

module "archived_zone_bucket" {
  source              = "terraform-aws-modules/s3-bucket/aws"
  acceleration_status = "Suspended"
  bucket              = "${local.name_prefix}-archive"

  # S3 bucket-level Public Access Block configuration
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = data.terraform_remote_state.kms.outputs.data_kms_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  expected_bucket_owner = data.aws_caller_identity.current.account_id
  tags                  = local.default_tags
}
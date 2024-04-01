module "data_kms" {
  source = "terraform-aws-modules/kms/aws"

  deletion_window_in_days = 7
  description             = "KMS key for data resources"
  enable_key_rotation     = true
  is_enabled              = true
  key_usage               = "ENCRYPT_DECRYPT"
  multi_region            = false

  # Policy
  enable_default_policy = true
  key_owners            = [local.current_identity]
  key_service_users     = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS"]
  key_statements        = [
    {
      sid     = "CloudWatchLogs"
      actions = [
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*"
      ]
      resources  = ["*"]
      principals = [
        {
          type        = "Service"
          identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
        }
      ]
      conditions = [
        {
          test     = "ArnLike"
          variable = "kms:EncryptionContext:aws:logs:arn"
          values   = [
            "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:*",
          ]
        }
      ]
    },
    {
      sid    = "Allow Specific AWS Services to encrypt data"
      action = [
        "kms:GenerateDataKey*",
        "kms:Decrypt"
      ],
      Resource   = "*"
      principals = [
        {
          type        = "Service"
          identifiers = [
            "dms.amazonaws.com",
            "redshift.amazonaws.com",
            "s3.amazonaws.com",
            "rds.amazonaws.com",
            "cloudwatch.amazonaws.com"
          ]
        }

      ]
    },
    {
      sid    = "Allow CloudTrail to encrypt data"
      action = [
        "kms:GenerateDataKey*"
      ],
      Resource   = "*"
      principals = [
        {
          type        = "Service"
          identifiers = ["cloudtrail.amazonaws.com"]
        }
      ]
      condition = {
        StringLike = {
          "kms:EncryptionContext:aws:cloudtrail:arn" = "arn:aws:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/*"
        }
      }

    },
    {
      sid    = "Allow CloudTrail to describe data"
      action = [
        "kms:DescribeKey"
      ],
      Resource   = "*"
      principals = [
        {
          type        = "Service"
          identifiers = ["cloudtrail.amazonaws.com"]
        }
      ]
    },
    {
      sid    = "Allow Principals in this account to decrypt log files"
      action = [
        "kms:Decrypt",
        "kms:ReEncryptFrom"
      ],
      Resource   = "*"
      principals = [
        {
          type        = "AWS"
          identifiers = ["*"]
        }
      ]
      condition = {
        StringEqual = {
          "kms:CallerAccount" = data.aws_region.current.name
        },
        StringLike = {
          "kms:EncryptionContext:aws:cloudtrail:arn" = "arn:aws:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/*"
        }
      }
    }


  ]

  # Aliases
  aliases = ["${var.prefix}${var.environment}-db-kms"]

  aliases_use_name_prefix = false

  tags = local.default_tags
}
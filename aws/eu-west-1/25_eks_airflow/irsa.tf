module "airflow_app_external_secret_irsa" {
  source                         = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version                        = "~> 5.0"
  role_name                      = "${local.name_prefix}-${local.k8s_airflow_namespace}-external-secret-irsa"
  attach_external_secrets_policy = true
  external_secrets_secrets_manager_arns = [
    "arn:aws:secretsmanager:${var.region}:${local.env.account_id}:secret:${data.terraform_remote_state.db_admin.outputs.airflow_db_secret_name}*"
  ]
  policy_name_prefix = "${local.name_prefix}-${local.k8s_airflow_namespace}-"

  oidc_providers = {
    ex = {
      provider_arn               = data.terraform_remote_state.eks.outputs.oidc_provider_arn
      namespace_service_accounts = ["${local.k8s_airflow_namespace}:${local.k8s_airflow_service_account_name}"]
    }
  }

  tags = merge(local.default_tags,
    {
      Name = "${local.name_prefix}-${local.k8s_airflow_namespace}-external-secret-irsa"
  })
}

resource "aws_iam_policy" "s3_logs_rw_bucket_policy" {
  name = "S3BucketAccessPolicy"
  description = "Policy to access specific s3 bucket prefix"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = "${data.terraform_remote_state.s3.outputs.s3_airflow_log_bucket_arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ],
        Resource = data.terraform_remote_state.s3.outputs.s3_airflow_log_bucket_arn,
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_airflow_policy_attachment" {
  role       = module.airflow_app_external_secret_irsa.iam_role_name
  policy_arn = aws_iam_policy.s3_logs_rw_bucket_policy.arn
}


module "external_airflow_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${local.name_prefix}-airflow-irsa"

  attach_external_secrets_policy                     = true
  external_secrets_ssm_parameter_arns                = ["arn:aws:ssm:*:*:parameter/${local.name_prefix}-*"]
  external_secrets_secrets_manager_arns              = ["arn:aws:secretsmanager:*:*:secret:${local.name_prefix}-*"]
  external_secrets_secrets_manager_create_permission = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["airflow:airflow-worker", "airflow:airflow-scheduler", "airflow:airflow-triggerer", "airflow:airflow-webserver"]
    }
  }


  tags = merge(local.default_tags, {
    Name                 = "${local.name_prefix}-airflow-irsa"
    git_commit           = "6e6d9d3878420ec6ee4c039f39968af0a51df6a0"
    git_file             = "eu-west-1/03_eks/irsa.tf"
    git_last_modified_at = "2024-02-02 21:38:57"
    git_modifiers        = "MoustafaAMahmoud"
    git_org              = "datasquadapp.ai"
    git_repo             = "datasquad-infra"
    yor_name             = "external_airflow_irsa_role"
    yor_trace            = "29f14fd6-59de-4058-8649-bdb2b6580a4c"
    git_last_modified_by = "malaa"
  })
}

resource "aws_iam_policy" "s3_logs_rw_bucket_policy" {
  name        = "S3BucketAccessPolicy"
  description = "Policy to access specific S3 bucket prefix"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = "arn:aws:s3:::tf-s3-prd-eu-west-1-logs/airflow/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ],
        Resource = "arn:aws:s3:::tf-s3-prd-eu-west-1-logs",
        #        Condition = {
        #          StringLike = {
        #            "s3:prefix" = ["airflow/*"]
        #          }
        #        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_airflow_policy_attachment" {
  role       = module.external_airflow_irsa_role.iam_role_name
  policy_arn = aws_iam_policy.s3_logs_rw_bucket_policy.arn
}
#https://github.com/awslabs/data-on-eks/blob/main/schedulers/terraform/self-managed-airflow/airflow-core.tf
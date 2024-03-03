
# https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotating-secrets-required-permissions-function.html
data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecretVersionStage",
    ]
    resources = [module.tf_secrets_manager_rotate_datasquad_app_backend_db.secret_arn]
  }

  statement {
    actions   = ["secretsmanager:GetRandomPassword"]
    resources = ["*"]
  }

  statement {
    actions   = ["secretsmanager:GetRandomPassword"]
    resources = ["*"]
  }
}
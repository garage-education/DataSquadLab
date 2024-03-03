module "tf_secrets_manager_rotate_datasquad_app_backend_db" {
  source = "terraform-aws-modules/secrets-manager/aws"

  # Secret
  name                    = "${local.name_prefix}-app-backend-db"
  description             = "Rotated example Secrets Manager secret"
  recovery_window_in_days = 0

  # Policy
  create_policy       = true
  block_public_policy = true
  policy_statements = {
    lambda = {
      sid = "LambdaReadWrite"
      principals = [{
        type        = "AWS"
        identifiers = [module.tf_sm_password_rotation_lambda.lambda_role_arn]
      }]
      actions = [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue",
        "secretsmanager:PutSecretValue",
        "secretsmanager:UpdateSecretVersionStage",
      ]
      resources = ["*"]
    }
    account = {
      sid = "AccountDescribe"
      principals = [{
        type        = "AWS"
        identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      }]
      actions   = ["secretsmanager:DescribeSecret"]
      resources = ["*"]
    }
  }

  # Version
  ignore_secret_changes = true
  secret_string = jsonencode({
    engine   = "postgres",
    host     = "tf-datasquad-app-db.cnuqwe8wwiea.eu-west-1.rds.amazonaws.com",
    username = "louisa",
    password = "ThisIsMySuperSecretString12356!"
    dbname   = "datasquad_app",
    port     = 5432
  })

  # Rotation
  enable_rotation     = true
  rotation_lambda_arn = module.tf_sm_password_rotation_lambda.lambda_function_arn
  rotation_rules = {
    # This should be more sensible in production
    schedule_expression = "rate(90 days)"
  }

  tags = merge(local.default_tags, {
    Name = "${local.name_prefix}-app-backend-db"
  })
}

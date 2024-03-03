
module "tf_sm_password_rotation_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 6.0"

  function_name = "${local.name_prefix}-sm-password-rotation-lambda"
  description   = "Example Secrets Manager secret rotation lambda function"

  handler     = "function.lambda_handler"
  runtime     = "python3.10"
  timeout     = 60
  memory_size = 512
  source_path = "${path.module}/function.py"

  attach_policy_json = true
  policy_json        = data.aws_iam_policy_document.this.json

  publish = true
  allowed_triggers = {
    secrets = {
      principal = "secretsmanager.amazonaws.com"
    }
  }

  cloudwatch_logs_retention_in_days = 7

  tags = merge(local.default_tags, {
    Name = "${local.name_prefix}-sm-password-rotation-lambda"
  })
}
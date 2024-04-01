data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

data "terraform_remote_state" "eks" {
  backend = "s3"
  config  = {
    bucket = "datasquad-terraform-state-backend"
    key    = "04_eks/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "db_admin" {
  backend = "s3"
  config  = {
    bucket = "datasquad-terraform-state-backend"
    key    = "17_eks_db_admin/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "s3" {
  backend = "s3"
  config  = {
    bucket = "datasquad-terraform-state-backend"
    key = "02_s3/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "aws_secretsmanager_secret" "airflow_source_secret_rds_psql_prod" {
  arn = data.terraform_remote_state.db_admin.outputs.airflow_db_secret_arn
}

data "aws_secretsmanager_secret_version" "airflow_secret_prod_psql_current" {
  secret_id     = data.aws_secretsmanager_secret.airflow_source_secret_rds_psql_prod.id
  version_stage = "AWSCURRENT"
}
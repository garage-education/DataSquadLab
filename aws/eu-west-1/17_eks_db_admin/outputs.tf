output "metabase_db_secret_arn" {
  description = "The arn of the metabase secret"
  value       = module.metabase_aws_secrets_manager.secret_arn
}

output "metabase_db_secret_id" {
  description = "The id of the metabase secret"
  value       = module.metabase_aws_secrets_manager.secret_id
}

output "metabase_db_secret_name" {
  description = "Metabase secret manager metabase name"
  value       = local.aws_metabase_secret_manager_name
}

output "airflow_db_secret_arn" {
  description = "The arn of the airflow secret"
  value       = module.airflow_aws_secrets_manager.secret_arn
}

output "airflow_db_secret_id" {
  description = "The id of the airflow secret"
  value       = module.airflow_aws_secrets_manager.secret_id
}

output "airflow_db_secret_name" {
  description = "airflow secret manager name"
  value       = local.aws_airflow_secret_manager_name
}
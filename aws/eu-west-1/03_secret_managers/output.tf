################################################################################
# Rotate
################################################################################

output "datasquad_app_backend_db_secret_arn" {
  description = "The ARN of the secret"
  value       = module.tf_secrets_manager_rotate_datasquad_app_backend_db.secret_arn
}

output "datasquad_app_backend_db_secret_id" {
  description = "The ID of the secret"
  value       = module.tf_secrets_manager_rotate_datasquad_app_backend_db.secret_id
}

output "datasquad_app_backend_db_secret_replica" {
  description = "Attributes of the replica created"
  value       = module.tf_secrets_manager_rotate_datasquad_app_backend_db.secret_replica
}

output "datasquad_app_backend_db_secret_version_id" {
  description = "The unique identifier of the version of the secret"
  value       = module.tf_secrets_manager_rotate_datasquad_app_backend_db.secret_version_id
}

output "datasquad_app_backend_db_secret_name" {
  description = "The name of the secret"
  value       = "${local.name_prefix}-app-backend-db"
}


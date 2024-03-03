output "datasquad_be_app_rds_db_address" {
  description = "The address of the RDS instance"
  value       = module.datasquad_be_app_rds_db.db_instance_address
}

output "datasquad_be_app_rds_db_arn" {
  description = "The ARN of the RDS instance"
  value       = module.datasquad_be_app_rds_db.db_instance_arn
}

output "datasquad_be_app_rds_db_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = module.datasquad_be_app_rds_db.db_instance_availability_zone
}

output "datasquad_be_app_rds_db_endpoint" {
  description = "The connection endpoint"
  value       = module.datasquad_be_app_rds_db.db_instance_endpoint
}
#
#output "datasquad_be_app_rds_db_engine" {
#  description = "The database engine"
#  value       = module.datasquad_be_app_rds_db.db_instance_engine
#}

output "datasquad_be_app_rds_db_engine_version_actual" {
  description = "The running version of the database"
  value       = module.datasquad_be_app_rds_db.db_instance_engine_version_actual
}

output "datasquad_be_app_rds_db_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = module.datasquad_be_app_rds_db.db_instance_hosted_zone_id
}

output "datasquad_be_app_rds_db_identifier" {
  description = "The RDS instance identifier"
  value       = module.datasquad_be_app_rds_db.db_instance_identifier
}

output "datasquad_be_app_rds_db_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = module.datasquad_be_app_rds_db.db_instance_resource_id
}

output "datasquad_be_app_rds_db_status" {
  description = "The RDS instance status"
  value       = module.datasquad_be_app_rds_db.db_instance_status
}

#output "datasquad_be_app_rds_db_name" {
#  description = "The database name"
#  value       = module.datasquad_be_app_rds_db.db_instance_name
#}

output "datasquad_be_app_rds_db_username" {
  description = "The master username for the database"
  value       = module.datasquad_be_app_rds_db.db_instance_username
  sensitive   = true
}

#output "datasquad_be_app_rds_db_port" {
#  description = "The database port"
#  value       = module.datasquad_be_app_rds_db.db_instance_port
#}

output "datasquad_be_app_rds_db_subnet_group_id" {
  description = "The db subnet group name"
  value       = module.datasquad_be_app_rds_db.db_subnet_group_id
}

output "datasquad_be_app_rds_db_subnet_group_arn" {
  description = "The ARN of the db subnet group"
  value       = module.datasquad_be_app_rds_db.db_subnet_group_arn
}

output "datasquad_be_app_rds_db_parameter_group_id" {
  description = "The db parameter group id"
  value       = module.datasquad_be_app_rds_db.db_parameter_group_id
}

output "datasquad_be_app_rds_db_parameter_group_arn" {
  description = "The ARN of the db parameter group"
  value       = module.datasquad_be_app_rds_db.db_parameter_group_arn
}

output "datasquad_be_app_rds_db_enhanced_monitoring_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the monitoring role"
  value       = module.datasquad_be_app_rds_db.enhanced_monitoring_iam_role_arn
}

output "datasquad_be_app_rds_db_cloudwatch_log_groups" {
  description = "Map of CloudWatch log groups created and their attributes"
  value       = module.datasquad_be_app_rds_db.db_instance_cloudwatch_log_groups
}

output "datasquad_be_app_rds_db_master_user_secret_arn" {
  description = "The ARN of the master user secret (Only available when manage_master_user_password is set to true)"
  value       = module.datasquad_be_app_rds_db.db_instance_master_user_secret_arn
}

output "datasquad_be_app_rds_db_key_arn" {
  description = "DB encrypted KMS ID"
  value       = module.datasquad_app_db_kms.key_arn
}

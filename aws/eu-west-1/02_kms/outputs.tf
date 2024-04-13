################################################################################
# DB KMS
################################################################################

output "data_kms_key_arn" {
  description = "The Amazon Resource Name (ARN) of the key"
  value       = module.data_kms.key_arn
}

output "data_kms_key_id" {
  description = "The globally unique identifier for the key"
  value       = module.data_kms.key_id
}

output "data_kms_key_policy" {
  description = "The IAM resource policy set on the key"
  value       = module.data_kms.key_policy
}

output "data_kms_external_key_expiration_model" {
  description = "Whether the key material expires. Empty when pending key material import, otherwise `KEY_MATERIAL_EXPIRES` or `KEY_MATERIAL_DOES_NOT_EXPIRE`"
  value       = module.data_kms.external_key_expiration_model
}

output "data_kms_external_key_state" {
  description = "The state of the CMK"
  value       = module.data_kms.external_key_state
}

output "data_kms_external_key_usage" {
  description = "The cryptographic operations for which you can use the CMK"
  value       = module.data_kms.external_key_usage
}

output "data_kms_aliases" {
  description = "A map of aliases created and their attributes"
  value       = module.data_kms.aliases
}

output "data_kms_grants" {
  description = "A map of grants created and their attributes"
  value       = module.data_kms.grants
}

################################################################################
# app KMS
################################################################################

output "app_kms_key_arn" {
  description = "The Amazon Resource Name (ARN) of the key"
  value       = module.app_kms.key_arn
}

output "app_kms_key_id" {
  description = "The globally unique identifier for the key"
  value       = module.app_kms.key_id
}

output "app_kms_key_policy" {
  description = "The IAM resource policy set on the key"
  value       = module.app_kms.key_policy
}

output "app_kms_external_key_expiration_model" {
  description = "Whether the key material expires. Empty when pending key material import, otherwise `KEY_MATERIAL_EXPIRES` or `KEY_MATERIAL_DOES_NOT_EXPIRE`"
  value       = module.app_kms.external_key_expiration_model
}

output "app_kms_external_key_state" {
  description = "The state of the CMK"
  value       = module.app_kms.external_key_state
}

output "app_kms_external_key_usage" {
  description = "The cryptographic operations for which you can use the CMK"
  value       = module.app_kms.external_key_usage
}

output "app_kms_aliases" {
  description = "A map of aliases created and their attributes"
  value       = module.app_kms.aliases
}

output "app_kms_grants" {
  description = "A map of grants created and their attributes"
  value       = module.app_kms.grants
}
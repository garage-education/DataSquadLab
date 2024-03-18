variable "prefix" {}
variable "name" {}
variable "owner" {}
variable "environment" {}
variable "region" {}
variable "vpc_cidr" {}
variable "ManagedBy" {}
variable "db_namespace_name" { default = "db"}
variable "db_service_account_name" { default = "rds-admin-external-secret-sa"}
variable "db_external_secret_store_name" { default = "tf-datasquad-rds-db-store"}
variable "metabase_namespace_name" {default = "metabase"}

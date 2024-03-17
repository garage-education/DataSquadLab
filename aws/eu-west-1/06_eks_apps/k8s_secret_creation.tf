module "rds_admin_k8s_external_secret" {
  depends_on           = [kubernetes_manifest.k8s_secretstore_db_admin_external_store]
  source               = "../../../k8s/modules/db_provisioner"
  external_secret_name = "${local.name_prefix}-rds-admin-external-secret"
  secret_map           = [
    {
      external_sm_name     = "tf-rds-admin-secret"
      external_sm_name_key = "POSTGRES_HOST"
      k8s_property_key     = "PGHOST"
    },
    {
      external_sm_name     = "tf-rds-admin-secret"
      external_sm_name_key = "PGDATABASE"
      k8s_property_key     = "POSTGRES_DB"
    },
    {
      external_sm_name     = "tf-rds-admin-secret"
      external_sm_name_key = "POSTGRES_PORT"
      k8s_property_key     = "PGPORT"
    },
    {
      external_sm_name     = "rds!db-390eb28a-2563-4d84-b9f1-9b3205f59365"
      external_sm_name_key = "POSTGRES_PORT"
      k8s_property_key     = "password"
    },
    {
      external_sm_name     = "rds!db-390eb28a-2563-4d84-b9f1-9b3205f59365"
      external_sm_name_key = "POSTGRES_PORT"
      k8s_property_key     = "username"
    }
  ]

  refresh_rate               = "1h"
  external_secret_store_name = kubernetes_manifest.k8s_secretstore_db_admin_external_store.manifest.metadata.name
  namespace_name             = kubernetes_manifest.namespace_db.manifest.metadata.name

}
module "metabase_k8s_external_secret" {
  depends_on           = [kubernetes_manifest.k8s_secretstore_db_admin_external_store]
  source               = "../../../k8s/modules/db_provisioner"
  external_secret_name = "${local.name_prefix}-metabase-external-secret"
  secret_map           = [
    {
      external_sm_name     = "tf-metabase-db-secret"
      external_sm_name_key = "MB_DB_USER"
      k8s_property_key     = "database_user"
    },
    {
      external_sm_name     = "tf-metabase-db-secret"
      external_sm_name_key = "MB_DB_PASS"
      k8s_property_key     = "database_password"
    },
    {
      external_sm_name     = "tf-metabase-db-secret"
      external_sm_name_key = "MB_DB_DBNAME"
      k8s_property_key     = "database_name"
    }
  ]

  refresh_rate               = "1h"
  external_secret_store_name = kubernetes_manifest.k8s_secretstore_db_admin_external_store.manifest.metadata.name
  namespace_name             = kubernetes_manifest.namespace_db.manifest.metadata.name
}
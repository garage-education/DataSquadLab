module "rds_admin_k8s_external_secret" {
  depends_on           = [kubernetes_manifest.k8s_secretstore_db_admin_external_store]
  source               = "../../../k8s/modules/db_provisioner"
  external_secret_name = local.rds_external_admin_db_secret_name
  secret_map           = [
    {
      external_sm_name     = "tf-rds-db-admin-secret"
      external_sm_name_key = "POSTGRES_HOST"
      k8s_property_key     = "PGHOST"
    },
    {
      external_sm_name     = "tf-rds-db-admin-secret"
      external_sm_name_key = "POSTGRES_DB"
      k8s_property_key     = "PGDATABASE"
    },
    {
      external_sm_name     = "tf-rds-db-admin-secret"
      external_sm_name_key = "POSTGRES_PORT"
      k8s_property_key     = "PGPORT"
    },
    {
      external_sm_name     = "rds!db-390eb28a-2563-4d84-b9f1-9b3205f59365"
      external_sm_name_key = "password"
      k8s_property_key     = "PGPASSWORD"
    },
    {
      external_sm_name     = "rds!db-390eb28a-2563-4d84-b9f1-9b3205f59365"
      external_sm_name_key = "username"
      k8s_property_key     = "PGUSER"
    }
  ]

  refresh_rate               = "1h"
  external_secret_store_name = kubernetes_manifest.k8s_secretstore_db_admin_external_store.manifest.metadata.name
  namespace_name             = kubernetes_manifest.k8s_namespace_db.manifest.metadata.name

}

module "metabase_k8s_external_secret" {
  depends_on           = [kubernetes_manifest.k8s_secretstore_db_admin_external_store]
  source               = "../../../k8s/modules/db_provisioner"
  external_secret_name = local.metabase_external_secret_name
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
  namespace_name             = kubernetes_manifest.k8s_namespace_db.manifest.metadata.name
}
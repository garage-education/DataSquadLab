module "rds_admin_k8s_external_secret" {
  depends_on           = [kubernetes_manifest.k8s_secretstore_db_admin_external_store]
  source               = "../../../k8s/modules/db_provisioner"
  external_secret_name = local.k8s_db_rds_admin_external_secret_name
  secret_map           = [
    {
      external_sm_name     = local.aws_rds_db_admin_external_secret_name
      external_sm_name_key = "POSTGRES_HOST"
      k8s_property_key     = "PGHOST"
    },
    {
      external_sm_name     = local.aws_rds_db_admin_external_secret_name
      external_sm_name_key = "POSTGRES_DB"
      k8s_property_key     = "PGDATABASE"
    },
    {
      external_sm_name     = local.aws_rds_db_admin_external_secret_name
      external_sm_name_key = "POSTGRES_PORT"
      k8s_property_key     = "PGPORT"
    },
    {
      external_sm_name     = local.aws_rds_db_admin_managed_external_secret_name
      external_sm_name_key = "password"
      k8s_property_key     = "PGPASSWORD"
    },
    {
      external_sm_name     = local.aws_rds_db_admin_managed_external_secret_name
      external_sm_name_key = "username"
      k8s_property_key     = "PGUSER"
    }
  ]
  refresh_rate               = "1h"
  external_secret_store_name = kubernetes_manifest.k8s_secretstore_db_admin_external_store.manifest.metadata.name
  namespace_name             = kubernetes_namespace_v1.db.metadata[0].name
}
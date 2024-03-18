resource "kubernetes_manifest" "k8s_namespace_airflow" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Namespace"
    "metadata"   = {
      "labels" = {
        "app"                        = var.airflow_namespace_name
        "app.kubernetes.io/instance" = var.airflow_namespace_name
        "app.kubernetes.io/name"     = var.airflow_namespace_name
      }
      "name" = var.airflow_namespace_name
    }
  }
}

## TODO: convert this to terraform module
resource "kubernetes_manifest" "job_db_airflow_postgres_db_create_job" {
  depends_on = [module.airflow_db_k8s_external_secret]
  manifest   = {
    "apiVersion" = "batch/v1"
    "kind"       = "Job"
    "metadata"   = {
      "name"      = "airflow-postgres-db-create-job"
      "namespace" = var.db_namespace_name
    }
    "spec" = {
      "template" = {
        "spec" = {
          "containers" = [
            {
              "args" = [
                "psql -a -f /sql/init.sql -v database_user=$database_user -v database_password=$database_password -v database_name=$database_name",
              ]
              "command" = [
                "sh",
                "-c",
              ]
              "envFrom" = [
                {
                  "secretRef" = {
                    "name" = local.rds_k8s_external_admin_db_secret_name
                  }
                },
                {
                  "secretRef" = {
                    "name" = local.airflow_k8s_external_secret_name
                  }
                },
              ]
              "image"        = "postgres"
              "name"         = "init-postgres"
              "volumeMounts" = [
                {
                  "mountPath" = "/sql"
                  "name"      = "sql-init"
                },
              ]
            },
          ]
          "restartPolicy" = "OnFailure"
          "volumes"       = [
            {
              "configMap" = {
                "name" = "postgres-init-sql"
              }
              "name" = "sql-init"
            },
          ]
        }
      }
    }
  }
}
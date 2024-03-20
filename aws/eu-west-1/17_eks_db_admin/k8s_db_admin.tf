resource "kubernetes_namespace_v1" "db" {
  metadata {
    labels = {
      "app"                        = local.k8s_db_namespace_name
      "app.kubernetes.io/instance" = local.k8s_db_namespace_name
      "app.kubernetes.io/name"     = local.k8s_db_namespace_name
    }
    name = local.k8s_db_namespace_name
  }
}

resource "kubernetes_service_account_v1" "db_admin_sa" {
  depends_on = [kubernetes_namespace_v1.db]
  metadata {
    name        = local.k8s_db_rds_admin_service_account_name
    namespace   = kubernetes_namespace_v1.db.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = module.rds_admin_external_secret_irsa_role.iam_role_arn
    }
    labels = {
      "app.kubernetes.io/instance" = local.k8s_db_rds_admin_service_account_name
      "app.kubernetes.io/name"     = local.k8s_db_rds_admin_service_account_name
    }
  }
}

resource "kubernetes_manifest" "k8s_secretstore_db_admin_external_store" {
  depends_on = [kubernetes_service_account_v1.db_admin_sa]
  manifest   = {
    "apiVersion" = "external-secrets.io/v1beta1"
    "kind"       = "SecretStore"
    "metadata"   = {
      "name"      = local.k8s_db_rds_admin_external_secret_store_name
      "namespace" = kubernetes_namespace_v1.db.metadata[0].name
    }
    "spec" = {
      "provider" = {
        "aws" = {
          "auth" = {
            "jwt" = {
              "serviceAccountRef" = {
                "name" = kubernetes_service_account_v1.db_admin_sa.metadata[0].name
              }
            }
          }
          "region"  = var.region
          "service" = "SecretsManager"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "configmap_db_postgres_init_sql" {
  manifest = {
    "apiVersion" = "v1"
    "data"       = {
      "init.sql" = <<-EOT
      CREATE USER :database_user WITH PASSWORD :'database_password';
      CREATE DATABASE :database_name;
      GRANT ALL PRIVILEGES ON DATABASE :database_name TO :database_user;
      EOT
    }
    "kind"     = "ConfigMap"
    "metadata" = {
      "name"      = "postgres-init-sql"
      "namespace" = local.k8s_db_namespace_name
    }
  }
}

resource "kubernetes_manifest" "configmap_db_postgres_db_drop" {
  manifest = {
    "apiVersion" = "v1"
    "data"       = {
      "drop.sql" = <<-EOT
      DROP DATABASE IF EXISTS :database_name;
      DROP USER IF EXISTS :database_user;
      EOT
    }
    "kind"     = "ConfigMap"
    "metadata" = {
      "name"      = "postgres-db-drop"
      "namespace" = local.k8s_db_namespace_name
    }
  }
}
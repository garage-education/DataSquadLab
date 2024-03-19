resource "kubernetes_namespace_v1" "db" {
  metadata {
    labels = {
      "app"                        = local.db_namespace_name
      "app.kubernetes.io/instance" = local.db_namespace_name
      "app.kubernetes.io/name"     = local.db_namespace_name
    }
    name = local.db_namespace_name
  }
}

resource "kubernetes_service_account_v1" "db_admin_sa" {
  depends_on = [kubernetes_namespace_v1.db]
  metadata {
    name        = local.db_service_account_name
    namespace   = kubernetes_namespace_v1.db.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::730335474513:role/tf-datasquad-eks-rds-admin-irsa"
      #TODO: get this from outputs
    }
    labels = {
      "app.kubernetes.io/instance" = local.db_service_account_name
      "app.kubernetes.io/name"     = local.db_service_account_name
    }
  }
}

resource "kubernetes_manifest" "k8s_secretstore_db_admin_external_store" {
  depends_on = [kubernetes_service_account_v1.db_admin_sa]
  manifest   = {
    "apiVersion" = "external-secrets.io/v1beta1"
    "kind"       = "SecretStore"
    "metadata"   = {
      "name"      = local.db_external_secret_store_name
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
      "namespace" = local.db_namespace_name
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
      "namespace" = local.db_namespace_name
    }
  }
}
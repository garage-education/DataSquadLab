resource "kubernetes_manifest" "k8s_namespace_db" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Namespace"
    "metadata"   = {
      "labels" = {
        "app"                        = var.db_namespace_name
        "app.kubernetes.io/instance" = var.db_namespace_name
        "app.kubernetes.io/name"     = var.db_namespace_name
      }
      "name" = var.db_namespace_name
    }
  }
}

resource "kubernetes_manifest" "k8s_serviceaccount_db_rds_admin" {
  depends_on = [kubernetes_manifest.k8s_namespace_db]
  manifest   = {
    "apiVersion"                   = "v1"
    "automountServiceAccountToken" = true
    "kind"                         = "ServiceAccount"
    "metadata"                     = {
      "annotations" = {
        "eks.amazonaws.com/role-arn" = "arn:aws:iam::730335474513:role/tf-datasquad-eks-rds-admin-irsa" #TODO: to be automated
      }
      "labels" = {
        "app.kubernetes.io/instance" = var.db_service_account_name
        "app.kubernetes.io/name"     = var.db_service_account_name
      }
      "name"      = var.db_service_account_name
      "namespace" = kubernetes_manifest.k8s_namespace_db.manifest.metadata.name
    }
  }
}

resource "kubernetes_manifest" "k8s_secretstore_db_admin_external_store" {
  depends_on = [kubernetes_manifest.k8s_serviceaccount_db_rds_admin]
  manifest   = {
    "apiVersion" = "external-secrets.io/v1beta1"
    "kind"       = "SecretStore"
    "metadata"   = {
      "name"      = var.db_external_secret_store_name
      "namespace" = kubernetes_manifest.k8s_namespace_db.manifest.metadata.name
    }
    "spec" = {
      "provider" = {
        "aws" = {
          "auth" = {
            "jwt" = {
              "serviceAccountRef" = {
                "name" = kubernetes_manifest.k8s_serviceaccount_db_rds_admin.manifest.metadata.name
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
    "data" = {
      "init.sql" = <<-EOT
      CREATE USER :database_user WITH PASSWORD :'database_password';
      CREATE DATABASE :database_name;
      GRANT ALL PRIVILEGES ON DATABASE :database_name TO :database_user;
      EOT
    }
    "kind" = "ConfigMap"
    "metadata" = {
      "name" = "postgres-init-sql"
      "namespace" = var.db_namespace_name
    }
  }
}

resource "kubernetes_manifest" "configmap_db_postgres_db_drop" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "drop.sql" = <<-EOT
      DROP DATABASE IF EXISTS :database_name;
      DROP USER IF EXISTS :database_user;
      EOT
    }
    "kind" = "ConfigMap"
    "metadata" = {
      "name" = "postgres-db-drop"
      "namespace" = var.db_namespace_name
    }
  }
}
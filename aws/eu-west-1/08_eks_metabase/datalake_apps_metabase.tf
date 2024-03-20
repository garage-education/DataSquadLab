locals {
  k8s_metabase_namespace                  = "metabase"
  k8s_metabase_external_secret_store_name = "${local.name_prefix}-${local.k8s_metabase_namespace}-secret-store"
  k8s_metabase_service_account_name       = "${local.name_prefix}-${local.k8s_metabase_namespace}-external-secret-sa"
  k8s_metabase_external_secret_name       = "${local.name_prefix}-${local.name_prefix}-external-secret"

  aws_metabase_secret_manager_name        = data.terraform_remote_state.db_admin.outputs.metabase_db_secret_name

}

resource "kubernetes_namespace_v1" "metabase" {
  metadata {
    labels = {
      "app"                        = local.k8s_metabase_namespace
      "app.kubernetes.io/instance" = local.k8s_metabase_namespace
      "app.kubernetes.io/name"     = local.k8s_metabase_namespace
    }
    name = local.k8s_metabase_namespace
  }
}

resource "kubernetes_service_account_v1" "metabase_service_account" {
  depends_on = [kubernetes_namespace_v1.metabase]
  metadata {
    name        = local.k8s_metabase_service_account_name
    namespace   = local.k8s_metabase_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.metabase_app_external_secret_irsa.iam_role_arn
    }
    labels = {
      "app.kubernetes.io/instance" = local.k8s_metabase_service_account_name
      "app.kubernetes.io/name"     = local.k8s_metabase_service_account_name
    }
  }
}

resource "kubernetes_manifest" "k8s_secretstore_metabase_external_store" {
  depends_on = [kubernetes_service_account_v1.metabase_service_account]
  manifest   = {
    "apiVersion" = "external-secrets.io/v1beta1"
    "kind"       = "SecretStore"
    "metadata"   = {
      "name"      = local.k8s_metabase_external_secret_store_name
      "namespace" = kubernetes_namespace_v1.metabase.metadata[0].name
    }
    "spec" = {
      "provider" = {
        "aws" = {
          "auth" = {
            "jwt" = {
              "serviceAccountRef" = {
                "name" = kubernetes_service_account_v1.metabase_service_account.metadata[0].name
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

module "metabase_db_metabase_k8s_external_secret" {
  depends_on           = [kubernetes_manifest.k8s_secretstore_metabase_external_store]
  source               = "../../../k8s/modules/db_provisioner"
  external_secret_name = local.k8s_metabase_external_secret_name
  secret_map           = [
    {
      external_sm_name     = local.aws_metabase_secret_manager_name
      external_sm_name_key = "username"
      k8s_property_key     = "MB_DB_USER"
    },
    {
      external_sm_name     = local.aws_metabase_secret_manager_name
      external_sm_name_key = "password"
      k8s_property_key     = "MB_DB_PASS"
    },
    {
      external_sm_name     = local.aws_metabase_secret_manager_name
      external_sm_name_key = "jdbc_url"
      k8s_property_key     = "MB_DB_URL"
    }

  ]

  refresh_rate               = "1h"
  external_secret_store_name = kubernetes_manifest.k8s_secretstore_metabase_external_store.manifest.metadata.name
  namespace_name             = kubernetes_namespace_v1.metabase.metadata[0].name
}

resource "kubernetes_manifest" "application_argocd_metabase" {
  depends_on = [
    kubernetes_service_account_v1.metabase_service_account,
    module.metabase_db_metabase_k8s_external_secret
  ]
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata"   = {
      "name"      = "metabase"
      "namespace" = "argocd"
    }
    "spec" = {
      "destination" = {
        "namespace" = "metabase"
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source"  = {
        "chart" = "metabase"
        "helm"  = {
          "parameters" = [
            {
              "name"  = "serviceAccount.name"
              "value" = kubernetes_service_account_v1.metabase_service_account.metadata[0].name
            },
            {
              "name"  = "database.type"
              "value" = "postgres"
            },
            {
              "name"  = "ingress.enabled"
              "value" = "true"
            },
            {
              "name"  = "ingress.hosts[0]"
              "value" = "metabase.prod.datalake.garageeducation.org"
            },
            {
              "name"  = "listen.port"
              "value" = "3000"
            },
          ]
          "values" = <<-EOT
            database:
              existingSecret: ${local.k8s_metabase_external_secret_name}
              existingSecretConnectionURIKey: MB_DB_URL
              existingSecretUsernameKey: MB_DB_USER
              existingSecretPasswordKey: MB_DB_PASS
            ingress:
              className: nginx
              tls:
                - secretName: letsencrypt-production
                  hosts:
                    - metabase.prod.datalake.garageeducation.org
            EOT
        }
        "repoURL"        = "https://pmint93.github.io/helm-charts"
        "targetRevision" = "2.13.0"
      }
    }
  }
}

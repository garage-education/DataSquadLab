## TODO: convert this to terraform module
resource "kubernetes_manifest" "job_db_metabase_postgres_db_create_job" {
  depends_on = [module.metabase_db_k8s_external_secret]
  manifest   = {
    "apiVersion" = "batch/v1"
    "kind"       = "Job"
    "metadata"   = {
      "name"      = "metabase-postgres-db-create-job"
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
                    "name" = local.metabase_k8s_external_secret_name
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

resource "kubernetes_namespace_v1" "metabase" {
  metadata {
    labels = {
      "app"                        = var.metabase_namespace_name
      "app.kubernetes.io/instance" = var.metabase_namespace_name
      "app.kubernetes.io/name"     = var.metabase_namespace_name
    }
    name = var.metabase_namespace_name
  }
}

resource "kubernetes_service_account_v1" "metabase_service_account" {
  depends_on = [kubernetes_namespace_v1.metabase]
  metadata {
    name        = var.metabase_service_account_name
    namespace   = var.metabase_namespace_name
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::730335474513:role/tf-datasquad-eks-metabase-app-irsa" #TODO: get this from outputs
    }
    labels = {
      "app.kubernetes.io/instance" = var.metabase_service_account_name
      "app.kubernetes.io/name"     = var.metabase_service_account_name
    }
  }
}

resource "kubernetes_manifest" "k8s_secretstore_metabase_external_store" {
  depends_on = [kubernetes_service_account_v1.metabase_service_account]
  manifest   = {
    "apiVersion" = "external-secrets.io/v1beta1"
    "kind"       = "SecretStore"
    "metadata"   = {
      "name"      = var.metabase_external_secret_store_name
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
  external_secret_name = local.metabase_k8s_external_secret_name
  secret_map           = [
    {
      external_sm_name     = local.metabase_aws_external_secret_name
      external_sm_name_key = "MB_DB_USER"
      k8s_property_key     = "MB_DB_USER"
    },
    {
      external_sm_name     = local.metabase_aws_external_secret_name
      external_sm_name_key = "MB_DB_PASS"
      k8s_property_key     = "MB_DB_PASS"
    },
    {
      external_sm_name     = local.metabase_aws_external_secret_name
      external_sm_name_key = "MB_DB_URL"
      k8s_property_key     = "MB_DB_URL"
    }

  ]

  refresh_rate               = "1h"
  external_secret_store_name = kubernetes_manifest.k8s_secretstore_metabase_external_store.manifest.metadata.name
  namespace_name             = kubernetes_namespace_v1.metabase.metadata[0].name
}


resource "kubernetes_manifest" "application_argocd_metabase" {
  depends_on = [
    kubernetes_manifest.job_db_metabase_postgres_db_create_job, kubernetes_service_account_v1.metabase_service_account,
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
              existingSecret: ${local.metabase_k8s_external_secret_name}
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


locals {
  k8s_airflow_external_secret_store_name = "${local.name_prefix}-${local.k8s_airflow_namespace}-secret-store"
  k8s_airflow_external_secret_name       = "${local.name_prefix}-${local.k8s_airflow_namespace}-external-secret"

  aws_airflow_secret_manager_name        = data.terraform_remote_state.db_admin.outputs.airflow_db_secret_name

}

output "message" {
  value = "The value of the variable is: ${data.terraform_remote_state.rds.outputs.db_instance_address}"
}

resource "kubernetes_namespace_v1" "airflow" {
  metadata {
    labels = {
      "app"                        = local.k8s_airflow_namespace
      "app.kubernetes.io/instance" = local.k8s_airflow_namespace
      "app.kubernetes.io/name"     = local.k8s_airflow_namespace
    }
    name = local.k8s_airflow_namespace
  }
}

resource "kubernetes_service_account_v1" "airflow_service_account" {
  depends_on = [kubernetes_namespace_v1.airflow]
  metadata {
    name        = local.k8s_airflow_service_account_name
    namespace   = local.k8s_airflow_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.airflow_app_external_secret_irsa.iam_role_arn
    }
    labels = {
      "app.kubernetes.io/instance" = local.k8s_airflow_service_account_name
      "app.kubernetes.io/name"     = local.k8s_airflow_service_account_name
    }
  }
}

resource "kubernetes_manifest" "k8s_secretstore_airflow_external_store" {
  depends_on = [kubernetes_service_account_v1.airflow_service_account]
  manifest   = {
    "apiVersion" = "external-secrets.io/v1beta1"
    "kind"       = "SecretStore"
    "metadata"   = {
      "name"      = local.k8s_airflow_external_secret_store_name
      "namespace" = kubernetes_namespace_v1.airflow.metadata[0].name
    }
    "spec" = {
      "provider" = {
        "aws" = {
          "auth" = {
            "jwt" = {
              "serviceAccountRef" = {
                "name" = kubernetes_service_account_v1.airflow_service_account.metadata[0].name
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

module "airflow_db_airflow_k8s_external_secret" {
  depends_on           = [kubernetes_manifest.k8s_secretstore_airflow_external_store]
  source               = "../../../k8s/modules/db_provisioner"
  external_secret_name = local.k8s_airflow_external_secret_name
  secret_map           = [
    {
      external_sm_name     = local.aws_airflow_secret_manager_name
      external_sm_name_key = "username"
      k8s_property_key     = "AIRFLOW_DATABASE_USERNAME"
    },
    {
      external_sm_name     = local.aws_airflow_secret_manager_name
      external_sm_name_key = "password"
      k8s_property_key     = "AIRFLOW_DATABASE_PASSWORD"
    },
    {
      external_sm_name     = local.aws_airflow_secret_manager_name
      external_sm_name_key = "dbname"
      k8s_property_key     = "AIRFLOW_DATABASE_NAME"
    }

  ]

  external_secret_store_name = kubernetes_manifest.k8s_secretstore_airflow_external_store.manifest.metadata.name
  namespace_name             = kubernetes_namespace_v1.airflow.metadata[0].name
}

resource "kubernetes_manifest" "application_argocd_airflow" {
  depends_on = [
    kubernetes_service_account_v1.airflow_service_account,
    module.airflow_db_airflow_k8s_external_secret
  ]
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata"   = {
      "name"      = kubernetes_namespace_v1.airflow.metadata[0].name
      "namespace" = "argocd"
    }
    "spec" = {
      "destination" = {
        "namespace" = kubernetes_namespace_v1.airflow.metadata[0].name
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source"  = {
        "chart" = "airflow"
        "helm"  = {
          "parameters" = [
            {
              "name"  = "serviceAccount.name"
              "value" = kubernetes_service_account_v1.airflow_service_account.metadata[0].name
            },
            {
              "name"  = "serviceAccount.create"
              "value" = "false"
            },
            {
              "name"  = "serviceAccount.automountServiceAccountToken"
              "value" = "true"
            },
            {
              "name"  = "scheduler.automountServiceAccountToken"
              "value" = "true"
            },
            {
              "name"  = "web.automountServiceAccountToken"
              "value" = "true"
            },
            {
              "name"  = "worker.automountServiceAccountToken"
              "value" = "true"
            },
            {
              "name": "rbac.create"
              "value": "true"
            },
            {
              "name": "executor"
              "value": "KubernetesExecutor"
            },
            {
              "name": "redis.enabled"
              "value": "false"
            },
            {
              "name": "metrics.enabled"
              "value": "true"
            },
            {
              "name": "metrics.serviceMonitor.enabled"
              "value": "true"
            },
            {
              "name"  = "ingress.enabled"
              "value" = "true"
            },
            {
              "name"  = "ingress.ingressClassName"
              "value" = "nginx"
            },
            {
              "name"  = "ingress.hostname"
              "value" = "airflow.prod.datalake.garageeducation.org"
            },
            {
              "name"  = "ingress.tls"
              "value" = "true"
            },
            {
              "name"  = "auth.username" # TODO: Fetch from secret manager
              "value" = "admin"
            },
            {
              "name"  = "auth.password" # TODO: Fetch from secret manager
              "value" = "admin"
            },
            {
              "name"  = "ingress.tls"
              "value" = "true"
            },
            {
              "name"  = "postgresql.enabled"
              "value" = "false"
            },
            {
              "name"  = "externalDatabase.host"
              "value" = jsondecode(data.aws_secretsmanager_secret_version.airflow_secret_prod_psql_current.secret_string)["host"]
            },
            {
              "name"  = "externalDatabase.user"
              "value" = jsondecode(data.aws_secretsmanager_secret_version.airflow_secret_prod_psql_current.secret_string)["username"]
            },
            {
              "name"  = "externalDatabase.database"
              "value" = jsondecode(data.aws_secretsmanager_secret_version.airflow_secret_prod_psql_current.secret_string)["dbname"]
            },
            {
              "name"  = "externalDatabase.existingSecret"
              "value" = local.k8s_airflow_external_secret_name
            },
            {
              "name"  = "externalDatabase.existingSecretPasswordKey"
              "value" = "AIRFLOW_DATABASE_PASSWORD"
            },
            {
              "name"  = "git.dags.enabled"
              "value" = "false"
            },
            {
              "name"  = "git.dags.repositories[0].branch"
              "value" = "main"
            },
            {
              "name"  = "git.dags.repositories[0].name"
              "value" = "airflow_dags"
            },
            {
              "name"  = "git.dags.repositories[0].path"
              "value" = "./apps/airflow/dags/"
            },
            {
              "name"  = "git.dags.repositories[0].repository"
              "value" = "https://github.com/garage-education/DataSquadLab"
            },
            {
              "name"  = "loadExamples"
              "value" = "true"
            }
          ]
          "values" = <<-EOT
          ingress:
            annotations:
              cert-manager.io/cluster-issuer: letsencrypt-production
          extraEnvVars:
            - name: AIRFLOW__LOGGING__REMOTE_LOGGING
              value: 'True'
            - name: AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER
              value: 's3://${data.terraform_remote_state.s3.outputs.s3_airflow_log_bucket_id}/airflow'
            - name: AIRFLOW__LOGGING__LOGGING_LEVEL
              value: 'DEBUG'
          EOT
        }
        "repoURL"        = "https://charts.bitnami.com/bitnami"
        "targetRevision" = "17.2.4"
      }
    }
  }
}

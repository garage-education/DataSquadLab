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

resource "kubernetes_manifest" "namespace_metabase" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Namespace"
    "metadata"   = {
      "labels" = {
        "app"                        = var.metabase_namespace_name
        "app.kubernetes.io/instance" = var.metabase_namespace_name
        "app.kubernetes.io/name"     = var.metabase_namespace_name
      }
      "name" = var.metabase_namespace_name
    }
  }
}

resource "kubernetes_manifest" "application_argocd_metabase" {
  depends_on = [kubernetes_manifest.job_db_metabase_postgres_db_create_job]
  manifest   = {
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
      "sources" = [
        {
          "chart" = "metabase"
          "helm"  = {
            "parameters" = [
              {
                "name"  = "serviceAccount.name"
                "value" = "tf-datasquad-eks-metabase-sa"
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
            serviceAccount:
            annotations:
            eks.amazonaws.com/role-arn: "arn:aws:iam::730335474513:role/tf-datasquad-eks-metabase-app-irsa"
            database:
            existingSecret: tf-metabase-db-secret
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
      ]
    }
  }
}


locals {

  airflow_k8s_namespace_name             = "airflow"
  airflow_k8s_service_account_name       = "tf-datasquad-eks-airflow-sa"
  airflow_k8s_external_secret_store_name = "tf-datasquad-airflow-db-store"
  airflow_k8s_external_secret_name       = "${local.name_prefix}-airflow-external-secret"
  airflow_aws_external_secret_name       = "${local.name_prefix}-db-airflow-secret"
  airflow_db_user                        = "airflow"
  airflow_db_dbname                      = "airflow"

  airflow_db_secrets = {
    engine   = data.terraform_remote_state.rds.outputs.db_instance_engine,
    host     = data.terraform_remote_state.rds.outputs.db_instance_address,
    username = local.airflow_db_user,
    password = random_string.airflow_db_password.result
    dbname   = local.airflow_db_dbname,
    port     = data.terraform_remote_state.rds.outputs.db_instance_port
  }


}

### DB
resource "random_string" "airflow_db_password" {
  length           = 25
  special          = true
  override_special = "!$%&()*+,;<=>?[]`{|}~"
  lifecycle {
    ignore_changes = [override_special]
  }
}

module "airflow_aws_secrets_manager" {
  depends_on = [random_string.airflow_db_password]
  source     = "terraform-aws-modules/secrets-manager/aws"

  # Secret
  name                    = "${local.name_prefix}-db-airflow-secret"
  description             = "${local.name_prefix}-db-airflow-secret Secrets Manager secret"
  recovery_window_in_days = 0

  # Policy
  create_policy       = true
  block_public_policy = true
  policy_statements   = {
    read = {
      sid        = "AllowAccountRead"
      principals = [
        {
          type        = "AWS"
          identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
        }
      ]
      actions   = ["secretsmanager:GetSecretValue"]
      resources = ["*"]
    }
  }

  # Version
  ignore_secret_changes = true
  secret_string         = jsonencode(local.airflow_db_secrets)

  tags = local.default_tags
}

module "airflow_db_k8s_external_secret" {
  depends_on = [
    kubernetes_manifest.k8s_secretstore_db_admin_external_store,
    module.airflow_aws_secrets_manager
  ]
  source               = "../../../k8s/modules/db_provisioner"
  external_secret_name = local.airflow_k8s_external_secret_name
  secret_map           = [
    {
      external_sm_name     = local.airflow_aws_external_secret_name
      external_sm_name_key = "username"
      k8s_property_key     = local.k8s_property_key_external_secret_db_user
    },
    {
      external_sm_name     = local.airflow_aws_external_secret_name
      external_sm_name_key = "password"
      k8s_property_key     = local.k8s_property_key_external_secret_db_password
    },
    {
      external_sm_name     = local.airflow_aws_external_secret_name
      external_sm_name_key = "dbname"
      k8s_property_key     = local.k8s_property_key_external_secret_db_name
    }
  ] #TODO: to find a way to remove the password from the logs

  refresh_rate               = "1h"
  external_secret_store_name = kubernetes_manifest.k8s_secretstore_db_admin_external_store.manifest.metadata.name
  namespace_name             = kubernetes_namespace_v1.db.metadata[0].name
}

resource "kubernetes_job_v1" "airflow_postgres_db_create_job" {
  depends_on = [module.airflow_db_k8s_external_secret,module.airflow_db_k8s_external_secret]

  metadata {
    name      = "${kubernetes_namespace_v1.db.metadata[0].name}-postgres-${local.airflow_k8s_namespace_name}-create-job"
    namespace = local.db_namespace_name
  }

  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "init-postgres"
          image   = "postgres"
          command = ["sh", "-c"]
          args    = [
            "psql -a -f /sql/init.sql -v database_user=$database_user -v database_password=$database_password -v database_name=$database_name"
          ]
          env_from {
            secret_ref {
              name = local.rds_k8s_external_admin_db_secret_name
            }
          }
          env_from {
            secret_ref {
              name = local.airflow_k8s_external_secret_name
            }
          }
          volume_mount {
            name       = "sql-init"
            mount_path = "/sql"
          }
        }
        volume {
          name = "sql-init"

          config_map {
            name = "postgres-init-sql"
          }
        }
        restart_policy = "OnFailure"
      }
    }

    backoff_limit = 4
  }

  wait_for_completion = false
}

### Airflow
resource "kubernetes_namespace_v1" "airflow" {
  metadata {
    labels = {
      "app"                        = local.airflow_k8s_namespace_name
      "app.kubernetes.io/instance" = local.airflow_k8s_namespace_name
      "app.kubernetes.io/name"     = local.airflow_k8s_namespace_name
    }
    name = local.airflow_k8s_namespace_name
  }
}

module "airflow_app_external_secret_irsa" {
  source                                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version                               = "~> 5.0"
  role_name                             = "${local.name_prefix}-${local.airflow_k8s_namespace_name}-app-irsa"
  attach_external_secrets_policy        = true
  external_secrets_secrets_manager_arns = [module.airflow_aws_secrets_manager.secret_arn]
  policy_name_prefix = "${local.name_prefix}-${local.airflow_k8s_namespace_name}-app-"

  oidc_providers = {
    ex = {
      provider_arn               = data.terraform_remote_state.eks.outputs.oidc_provider_arn
      namespace_service_accounts = [
        "${kubernetes_namespace_v1.airflow.metadata[0].name}:${local.airflow_k8s_service_account_name}"
      ]
    }
  }

  tags = merge(local.default_tags,
    {
      Name = "${local.name_prefix}-${local.airflow_k8s_namespace_name}-app-irsa"
    })
}
##
resource "kubernetes_service_account_v1" "airflow_service_account" {
  depends_on = [kubernetes_namespace_v1.airflow]
  metadata {
    name        = local.airflow_k8s_service_account_name
    namespace   = local.airflow_k8s_namespace_name
    annotations = {
      "eks.amazonaws.com/role-arn" = module.airflow_app_external_secret_irsa.iam_role_arn
    }
    labels = {
      "app.kubernetes.io/instance" = local.airflow_k8s_service_account_name
      "app.kubernetes.io/name"     = local.airflow_k8s_service_account_name
    }
  }
}

resource "kubernetes_manifest" "k8s_secretstore_airflow_external_store" {
  depends_on = [kubernetes_service_account_v1.airflow_service_account]
  manifest   = {
    "apiVersion" = "external-secrets.io/v1beta1"
    "kind"       = "SecretStore"
    "metadata"   = {
      "name"      = local.airflow_k8s_external_secret_store_name
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
##
module "airflow_db_airflow_k8s_external_secret" {
  depends_on           = [kubernetes_manifest.k8s_secretstore_airflow_external_store]
  source               = "../../../k8s/modules/db_provisioner"
  external_secret_name = local.airflow_k8s_external_secret_name
  secret_map           = [
    {
      external_sm_name     = local.airflow_aws_external_secret_name
      external_sm_name_key = "username"
      k8s_property_key     = "AIRFLOW_USER"
    },
    {
      external_sm_name     = local.airflow_aws_external_secret_name
      external_sm_name_key = "password"
      k8s_property_key     = "AIRFLOW_PASSWORD"
    },
    {
      external_sm_name     = local.airflow_aws_external_secret_name
      external_sm_name_key = "engine"
      k8s_property_key     = "AIRFLOW_ENGINE"
    },
    {
      external_sm_name     = local.airflow_aws_external_secret_name
      external_sm_name_key = "host"
      k8s_property_key     = "AIRFLOW_HOST"
    },
    {
      external_sm_name     = local.airflow_aws_external_secret_name
      external_sm_name_key = "port"
      k8s_property_key     = "AIRFLOW_PORT"
    },
    {
      external_sm_name     = local.airflow_aws_external_secret_name
      external_sm_name_key = "dbname"
      k8s_property_key     = "AIRFLOW_DBNAME"
    }

  ]

  refresh_rate               = "1h"
  external_secret_store_name = kubernetes_manifest.k8s_secretstore_airflow_external_store.manifest.metadata.name
  namespace_name             = kubernetes_namespace_v1.airflow.metadata[0].name
}

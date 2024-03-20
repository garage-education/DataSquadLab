locals {
  k8s_metabase_namespace            = "metabase"
  k8s_metabase_external_secret_name = "${local.name_prefix}-${local.k8s_metabase_namespace}-external-secret"
  aws_metabase_secret_manager_name = "${local.name_prefix}-db-${local.k8s_metabase_namespace}-secret"

  metabase_db_secrets = {
    engine   = data.terraform_remote_state.rds.outputs.db_instance_engine,
    host     = data.terraform_remote_state.rds.outputs.db_instance_address,
    username = "metabase_admin",
    password = random_string.metabase_db_password.result
    dbname   = local.k8s_metabase_namespace,
    port     = data.terraform_remote_state.rds.outputs.db_instance_port
  }
}

### DB
resource "random_string" "metabase_db_password" {
  length           = 25
  special          = true
  override_special = "!$%&()*+,;<=>?[]`{|}~"
  lifecycle {
    ignore_changes = [override_special]
  }
}

#TODO: add these to ouput
module "metabase_aws_secrets_manager" {
  depends_on = [random_string.metabase_db_password]
  source     = "terraform-aws-modules/secrets-manager/aws"

  # Secret
  name                    = local.aws_metabase_secret_manager_name
  description             = "${local.name_prefix}-db-${local.k8s_metabase_namespace}-secret Secrets Manager secret"
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
  secret_string         = jsonencode(local.metabase_db_secrets)

  tags = local.default_tags
}

module "metabase_db_k8s_external_secret" {
  depends_on = [
    kubernetes_manifest.k8s_secretstore_db_admin_external_store,
    module.metabase_aws_secrets_manager
  ]
  source               = "../../../k8s/modules/db_provisioner"
  external_secret_name = local.k8s_metabase_external_secret_name
  secret_map           = [
    {
      external_sm_name     = local.aws_metabase_secret_manager_name
      external_sm_name_key = "username"
      k8s_property_key     = local.k8s_property_key_external_secret_db_user
    },
    {
      external_sm_name     = local.aws_metabase_secret_manager_name
      external_sm_name_key = "password"
      k8s_property_key     = local.k8s_property_key_external_secret_db_password
    },
    {
      external_sm_name     = local.aws_metabase_secret_manager_name
      external_sm_name_key = "dbname"
      k8s_property_key     = local.k8s_property_key_external_secret_db_name
    }
  ] #TODO: to find a way to remove the password from the logs

  refresh_rate               = "1h"
  external_secret_store_name = kubernetes_manifest.k8s_secretstore_db_admin_external_store.manifest.metadata.name
  namespace_name             = kubernetes_namespace_v1.db.metadata[0].name
}

resource "kubernetes_job_v1" "metabase_postgres_db_create_job" {
  depends_on = [module.metabase_db_k8s_external_secret, module.metabase_db_k8s_external_secret]

  metadata {
    name      = "${kubernetes_namespace_v1.db.metadata[0].name}-postgres-${local.k8s_metabase_namespace}-create-job"
    namespace = kubernetes_namespace_v1.db.metadata[0].name
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
              name = local.k8s_db_rds_admin_external_secret_name
            }
          }
          env_from {
            secret_ref {
              name = local.k8s_metabase_external_secret_name
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

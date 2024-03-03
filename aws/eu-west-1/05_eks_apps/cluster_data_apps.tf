#---------------------------------------------------------------
# Apache Airflow Webserver Secret
#---------------------------------------------------------------
resource "random_id" "airflow_webserver" {
  byte_length = 16
}

#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "airflow_webserver" {
  name                    = "airflow_webserver_secret_key_2"
  recovery_window_in_days = 0 # Set to zero for this example to force delete during Terraform destroy
}

resource "aws_secretsmanager_secret_version" "airflow_webserver" {
  secret_id     = aws_secretsmanager_secret.airflow_webserver.id
  secret_string = random_id.airflow_webserver.hex
}

#---------------------------------------------------------------
# Webserver Secret Key
#---------------------------------------------------------------
resource "kubernetes_manifest" "secret_airflow_webserver_secret_key" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "webserver-secret-key" = base64encode(aws_secretsmanager_secret_version.airflow_webserver.secret_string)
    }
    "kind" = "Secret"
    "metadata" = {
      "annotations" = {
        "meta.helm.sh/release-name"      = "airflow"
        "meta.helm.sh/release-namespace" = "airflow"
      }
      "labels" = {
        "app.kubernetes.io/managed-by" = "Helm"
      }
      "name"      = "${local.name_prefix}-airflow-webserver-secret-key"
      "namespace" = "airflow"
    }
    "type" = "Opaque"
  }
}
### Airflow
resource "helm_release" "airflow" {
  name             = "airflow"
  chart            = "airflow"
  namespace        = "airflow"
  repository       = "https://airflow.apache.org"
  version          = "1.12.0"
  timeout          = 300
  create_namespace = true
  values = [
    file("helm_values/airflow.yaml")
  ]
}

### metabase
resource "kubernetes_manifest" "application_argocd_metabase" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "metabase"
      "namespace" = "argocd"
    }
    "spec" = {
      "destination" = {
        "namespace" = "metabase"
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "path"           = "./metabase"
        "repoURL"        = "git@github.com:Update-For-Integrated-Business-AI/datasquad-argo-cd.git"
        "targetRevision" = "HEAD"
      }
      "syncPolicy" = {
        "automated" = {}
      }
    }
  }
}
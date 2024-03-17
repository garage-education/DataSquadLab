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
  depends_on = [module.metabase_k8s_external_secret]
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
        },
        {
          "path"           = "./apps/metabase/"
          "repoURL"        = "https://github.com/garage-education/DataSquadLab.git"
          "targetRevision" = "HEAD"
        },
      ]
      "syncPolicy" = {
        "automated"   = {}
        "syncOptions" = [
          "CreateNamespace=true",
        ]
      }
    }
  }
}

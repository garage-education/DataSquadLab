resource "kubernetes_manifest" "application_argocd_datasquad_app_api" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "datasquad-app-api"
      "namespace" = "argocd"
    }
    "spec" = {
      "destination" = {
        "namespace" = "datasquad-production"
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "path"           = "./datasquad-app-api/"
        "repoURL"        = "git@github.com:Update-For-Integrated-Business-AI/datasquad-argo-cd.git"
        "targetRevision" = "HEAD"
      }
      "syncPolicy" = {
        "automated" = {}
      }
    }
  }
}

resource "kubernetes_manifest" "application_argocd_receipts_system" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "receipts-system"
      "namespace" = "argocd"
    }
    "spec" = {
      "destination" = {
        "namespace" = "datasquad-production"
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "path"           = "datasquad-app-receipts-system/"
        "repoURL"        = "git@github.com:Update-For-Integrated-Business-AI/datasquad-argo-cd.git"
        "targetRevision" = "HEAD"
      }
      "syncPolicy" = {
        "automated" = {}
      }
    }
  }
}

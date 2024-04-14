resource "kubernetes_manifest" "application_argocd_infra" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind" = "Application"
    "metadata" = {
      "name" = "app-of-apps"
      "namespace" = "argocd"
    }
    "spec" = {
      "destination" = {
        "namespace" = "argocd"
        "name" = "in-cluster"
      }
      "project" = "default"
      "source" = {
        "path" = "./apps/argocd"
        "repoURL" = "https://github.com/garage-education/DataSquadLab.git"
        "targetRevision" = "argocd/revamp" # TODO: Before merging change to HEAD
      }
      "syncPolicy": {
        "automated": {}
      }
    }
  }
}

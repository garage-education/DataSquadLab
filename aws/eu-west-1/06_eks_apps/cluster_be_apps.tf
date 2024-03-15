resource "kubernetes_manifest" "application_argocd_petclinic" {
  depends_on = [helm_release.argo_cd]
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind" = "Application"
    "metadata" = {
      "name" = "petclinic"
      "namespace" = "argocd"
    }
    "spec" = {
      "destination" = {
        "namespace" = "petclinic"
        "server" = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "path" = "./apps/petclinic/"
        "repoURL" = "https://github.com/garage-education/DataSquadLab.git"
        "targetRevision" = "HEAD"
      }
    }
  }
}

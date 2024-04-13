####
resource "helm_release" "argo_cd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "6.7.2"
  create_namespace = true
  values           = [
    file("helm_values/argocd.yaml")
  ]
}
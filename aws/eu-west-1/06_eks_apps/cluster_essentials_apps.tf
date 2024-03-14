resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  version          = "4.9.1"
  create_namespace = true
  atomic           = true

  values = [
    file("helm_values/ingress-nginx.yaml")
  ]
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  version          = "1.13.3"
  create_namespace = true

  values = [
    file("helm_values/cert-manager.yaml")
  ]
}

#####
resource "helm_release" "argo_cd" {
  depends_on       = [helm_release.nginx_ingress,helm_release.cert_manager,kubernetes_manifest.clusterissuer_letsencrypt_production]
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
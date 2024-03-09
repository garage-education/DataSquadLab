resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  version          = "4.10.0"
  create_namespace = true
  atomic           = true

  values = [
    "${file("helm_values/ingress-nginx.yaml")}"
  ]

}

resource "helm_release" "argo_cd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "6.6.0"
  create_namespace = true

  values = [
    "${file("helm_values/argocd.yaml")}"
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
    "${file("helm_values/cert-manager.yaml")}"
  ]
}

### clusterissuer
resource "kubernetes_manifest" "clusterissuer_letsencrypt_production" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt-production"
    }
    "spec" = {
      "acme" = {
        "email" = "me@garageeducation.org"
        "privateKeySecretRef" = {
          "name" = "letsencrypt-production"
        }
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "solvers" = [
          {
            "http01" = {
              "ingress" = {
                "class" = "nginx"
              }
            }
          },
        ]
      }
    }
  }
}
### clusterissuer
resource "kubernetes_manifest" "clusterissuer_letsencrypt_production" {
  depends_on = [helm_release.cert_manager]
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata"   = {
      "name" = "letsencrypt-production"
    }
    "spec" = {
      "acme" = {
        "email"               = "me@garageeducation.org"
        "privateKeySecretRef" = {
          "name" = "letsencrypt-production"
        }
        "server"  = "https://acme-v02.api.letsencrypt.org/directory"
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

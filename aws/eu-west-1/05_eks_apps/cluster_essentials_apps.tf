#https://github.com/SM4527/EKS-Nginx-Ingress/blob/master/chart_values.yaml
resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.9.1"
  atomic           = true
  #timeout          = 300
  values = [file("helm_values/ingress-nginx.yaml")]
  set {
    name  = "cluster.enabled"
    value = "true"
  }
  set {
    name  = "metrics.enabled"
    value = "true"
  }
}

###### argo-cd
resource "helm_release" "argo_cd" {
  name             = "argo-cd"
  namespace        = "argocd" # Namespace where Argo CD will be installed
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.54.0" # Specify the version
  timeout          = 300
  atomic           = true
  create_namespace = true
  values           = [file("helm_values/argocd.yaml")]
}

##eso
resource "helm_release" "eso" {
  name             = "external-secrets"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  version          = "0.9.11"
  timeout          = 300
  atomic           = true
  create_namespace = true
}

### Cert Manager
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  version          = "1.13.3"
  timeout          = 300
  atomic           = true
  create_namespace = true
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com\\/role-arn"
    value = data.terraform_remote_state.eks.outputs.cert_manager_irsa_role_arn
  }
  values = [
    file("helm_values/cert-manager.yaml")
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
        "email" = "malaa@datasquadapp.ai"
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

### clusterissuer
resource "kubernetes_manifest" "clusterissuer_letsencrypt_staging" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt-staging"
    }
    "spec" = {
      "acme" = {
        "email" = "malaa@moustafa.uk"
        "privateKeySecretRef" = {
          "name" = "letsencrypt-staging"
        }
        "server" = "https://acme-staging-v02.api.letsencrypt.org/directory"
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
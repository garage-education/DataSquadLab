resource "kubernetes_manifest" "k8s_external_secret" {
  manifest = {
    "apiVersion" = "external-secrets.io/v1beta1"
    "kind"       = "ExternalSecret"
    "metadata"   = {
      "name"      = var.external_secret_name
      "namespace" = var.namespace_name
    }
    "spec" = {
      "data" = [
        for item in var.secret_map : {
          remoteRef = {
            key      = item.external_sm_name
            property = item.external_sm_name_key
          }
          secretKey = item.k8s_property_key
        }
      ]
      "refreshInterval" = var.refresh_rate
      "secretStoreRef"  = {
        "kind" = "SecretStore"
        "name" = var.external_secret_store_name
      }
      "target" = {
        "creationPolicy" = "Owner"
        "name"           = var.external_secret_name
      }
    }
  }
}

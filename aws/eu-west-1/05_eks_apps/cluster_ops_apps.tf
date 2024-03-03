resource "kubernetes_manifest" "application_argocd_monitoring" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "monitoring"
      "namespace" = "argocd"
    }
    "spec" = {
      "destination" = {
        "namespace" = "monitoring"
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "chart" = "kube-prometheus-stack"
        "helm" = {
          "parameters" = [
            {
              "name"  = "grafana.ingress.enabled"
              "value" = "true"
            },
            {
              "name"  = "prometheus.ingress.enabled"
              "value" = "false"
            },
            {
              "name"  = "prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues"
              "value" = "false"
            },
            {
              "name"  = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
              "value" = "false"
            },
          ]
          "values" = <<-EOT
          grafana:
            additionalDataSources:
              - name: Synthetic Monitoring
                type: grafana-synthetic-monitoring-datasource
            plugins:
              - grafana-synthetic-monitoring-app
            ingress:
              annotations:
                kubernetes.io/ingress.class: nginx
                cert-manager.io/cluster-issuer: "letsencrypt-production"
                kubernetes.io/tls-acme: "true"
              hosts:
                - grafana.prod.infra.datasquad.ai
              tls:
                - secretName: letsencrypt-production
                  hosts:
                  - grafana.prod.infra.datasquad.ai
          EOT
        }
        "repoURL"        = "https://prometheus-community.github.io/helm-charts"
        "targetRevision" = "56.8.2"
      }
      "syncPolicy" = {
        "automated" = {}
        "syncOptions" = [
          "CreateNamespace=true",
          "ServerSideApply=true"
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "application_argocd_logging" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "logging"
      "namespace" = "argocd"
    }
    "spec" = {
      "destination" = {
        "namespace" = "logging"
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "chart" = "loki-stack"
        "helm" = {
          "parameters" = [
            {
              "name"  = "fluent-bit.enabled"
              "value" = "true"
            },
            {
              "name"  = "promtail.enabled"
              "value" = "false"
            },
          ]
        }
        "repoURL"        = "https://grafana.github.io/helm-charts"
        "targetRevision" = "2.10.1"
      }
      "syncPolicy" = {
        "syncOptions" = [
          "CreateNamespace=true",
        ]
      }
    }
  }
}

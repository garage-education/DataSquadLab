#output "nginx_endpoint" {
#  value = "http://${data.kubernetes_service.nginx_ingress.status.0.load_balancer.0.ingress.0.hostname}"
#}
#output "load-balancer-hostname" {
#  value = data.kubernetes_service.ingress-nginx.status[0].load_balancer[0].ingress[0].hostname
#}
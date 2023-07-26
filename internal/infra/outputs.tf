#AKS
output "aks_name" {
  value = module.infra.aks_name
}
output "aks_id" {
  value = module.infra.aks_id
}
output "aks_host" {
  value     = module.infra.aks_host
  sensitive = true
}
output "cluster_ca_certificate" {
  value     = module.infra.cluster_ca_certificate
  sensitive = true
}
output "aks" {
  value     = "${yamldecode(module.infra.aks["internal-ptae-aks-01"].kube_config_raw).users[0].user.exec.args}"
  sensitive = true
}

#PublicIP for Ingress Controller
output "ingress_pubip" {
  value = module.infra.ingress_pubip
}

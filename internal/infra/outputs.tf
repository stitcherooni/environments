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

#MySQL Flexible Server
output "mysql_server_name" {
  value = module.infra.mysql_server_name
}
output "mysql_server_id" {
  value = module.infra.mysql_server_id
}
output "mysql_server_fqdn" {
  value = module.infra.mysql_server_fqdn
}
output "mysql_server_login" {
  value       = module.infra.mysql_server_login
  sensitive   = true
  description = "The Administrator login for the MySQL Flexible Server"
}
output "mysql_server_password" {
  value       = module.infra.mysql_server_password
  sensitive   = true
  description = "The Password associated with the administrator_login for the MySQL Flexible Server"
}
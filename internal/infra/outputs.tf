#Main
output "resource_group_name" {
  value = module.infra.resource_group_name
}
output "resource_group_id" {
  value = module.infra.resource_group_id
}

#AKS
output "aks_name" {
  value = module.infra.aks_name
}
output "aks_id" {
  value = module.infra.aks_id
}
output "aks_host" {
  value     = module.infra.az_kube_config[local.aks_conf.internal_aks.name].0.host
  sensitive = true
}
output "cluster_ca_certificate" {
  value     = module.infra.az_kube_config[local.aks_conf.internal_aks.name].0.cluster_ca_certificate
  sensitive = true
}
output "az_kube_config" {
  value     = module.infra.az_kube_config
  sensitive = true
}
output "az_kubelet_identity" {
  value     = module.infra.az_kubelet_identity
  sensitive = true
}
output "aks" {
  value     = "${yamldecode(module.infra.aks[local.aks_conf.internal_aks.name].kube_config_raw).users[0].user.exec.args}"
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

#MySQL Flexible Server Database
output "mysql_dev_db_name" {
  value = azurerm_mysql_flexible_database.ptaevent_dev.name
}
output "mysql_dev_db_id" {
  value = azurerm_mysql_flexible_database.ptaevent_dev.id
}
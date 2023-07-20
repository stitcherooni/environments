#AKS
output "aks_name" {
  value = module.infra.aks_name
}
output "aks_id" {
  value = module.infra.aks_id
}
output "aks_host" {
  value = module.infra.aks_host
  sensitive = true
}
output "client_certificate" {
  value = module.infra.client_certificate
  sensitive = true
}
output "client_key" {
  value = module.infra.client_key
  sensitive = true
}
output "cluster_ca_certificate" {
  value = module.infra.cluster_ca_certificate
  sensitive = true
}
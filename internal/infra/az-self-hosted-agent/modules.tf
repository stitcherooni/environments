# module "az_aks_secret" {
#   source = "../"
  
#   secret = local.secret
# }

module "az_aks_deployment" {
  source = "git::https://ptaevents@dev.azure.com/ptaevents/pta-events.co.uk/_git/terraform//modules/kubernetes-deployment"

  deployment_conf = local.deployment_conf
}


# output "secret_name" {
#   value     = module.az_aks_secret.secret_name.*.secret1.metadata.0.name
#   sensitive = true
# }
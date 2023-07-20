module "infra" {
  source = "git::https://ptaevents@dev.azure.com/ptaevents/pta-events.co.uk/_git/terraform//solutions/pta-events"

  #MAIN
  location = local.location

  #Environment Name
  env_name = local.env_name

  #VNet
  address_space = local.address_space

  #Subnet
  subnet_cidr = local.subnet_cidr

  #AKS
  aks_conf = local.aks_conf

  #Azure Role Assignment
  #role_assignment_params = local.role_assignment_params

  #Tags
  tags = local.tags
}

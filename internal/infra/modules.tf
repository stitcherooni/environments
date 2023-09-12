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
  role_assignment_params = local.role_assignment_params

  #Azure Private DNS 
  private_dns_zone_conf = local.private_dns_zone_conf

  #MySQL Flexible Server
  mysql_conf = local.mysql_conf

  #Azure Bastion Host
  bastion_conf = local.bastion_conf

  #Azure Kubernetes Secret
  secret = local.secret

  #Tags
  tags = local.tags
}

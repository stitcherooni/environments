module "pta-events" {
  source = "git::https://ptaevents@dev.azure.com/ptaevents/pta-events.co.uk/_git/terraform//solutions/pta-events"

  #MAIN
  location = local.location

  #Environment Name
  env_name = local.env_name

  #VNet
  address_space = local.address_space

  #Subnet
  subnet_cidr = local.subnet_cidr
}

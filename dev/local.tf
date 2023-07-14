locals {
  #Main
  tenant_id           = "ff9085aa-053a-4b01-8817-effac5fdfdce"
  subscription_id     = "31ee4a72-709d-4b02-bd0e-30b59dee8a4c"
  location            = "uksouth"
  env_name            = "dev"

  #VNet
  address_space = ["10.10.0.0/19"]

  #Subnet
  cidr_block         = element(local.address_space, 0)
  subnet_cidr_blocks = [ for cidr_block in cidrsubnets(local.cidr_block, 3, 9) : cidr_block ]

  subnet_cidr = {
    "aks_cidr_blocks" = {
      subnet_name       = "${local.env_name}-ptae-aks-subnet"
      cidr              = element(local.subnet_cidr_blocks, 0) #["10.10.4.0/22"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegations       = {}
    }
    "mysql_cidr_blocks" = {
      subnet_name       = "${local.env_name}-ptae-mysql-subnet"
      cidr              = element(local.subnet_cidr_blocks, 1) #["10.10.4.128/28"]
      service_endpoints = ["Microsoft.Storage"]
      delegations = {
        delegation_name = "Microsoft.DBforMySQL/flexibleServers"
        actions         = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
  }
}
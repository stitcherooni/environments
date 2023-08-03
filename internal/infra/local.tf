locals {
  #Main
  tenant_id       = "ff9085aa-053a-4b01-8817-effac5fdfdce"
  subscription_id = "31ee4a72-709d-4b02-bd0e-30b59dee8a4c"
  owners          = "65e0258d-d870-4255-9835-4e7d3030e48b" #Owners AzureAD Group
  location        = "uksouth"
  env_name        = "internal"

  #VNet
  address_space = ["10.10.0.0/19"]

  #Subnet
  cidr_block         = element(local.address_space, 0)
  subnet_cidr_blocks = [for cidr_block in cidrsubnets(local.cidr_block, 3, 9, 10) : cidr_block]

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
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegations = {
        delegation_name = "Microsoft.DBforMySQL/flexibleServers"
        actions         = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
    "service_cidr_blocks" = {
      subnet_name       = "${local.env_name}-ptae-service-subnet"
      cidr              = element(local.subnet_cidr_blocks, 2)
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegations       = {}
    }
  }

  #AKS
  aks_conf = {
    "internal_aks" = {
      name                              = "${local.env_name}-ptae-aks-01"
      azure_policy_enabled              = true
      sku_tier                          = "Free"
      kubernetes_version                = "1.27.1"
      role_based_access_control_enabled = true
      azad_rbac = {
        rbac_managed       = true
        azure_rbac_enabled = true
        tenant_id          = local.tenant_id
        admin_group_object_ids = [
          local.owners,
          "f0d65a66-583b-4952-86a5-035ad00a42cd", #stanislav.bahmet
          "b170c8f9-699e-4dc8-bab0-d711992d290c", #sergii.voichuk
          "2b0356ea-7015-469e-913c-9687658af716", #david.cooke
          "eea5217b-f127-4fc1-b510-26d0a22c61fd", #internal-adm-sp-01
        ]
      }
      network_profile = {
        network_plugin = "azure"
        network_policy = "azure"
      }
      default_node_pool = {
        vm_size        = "Standard_D2as_v4"
        vnet_subnet_id = module.infra.subnet_id[local.subnet_cidr.aks_cidr_blocks.subnet_name]
        #zones              = [2]
        enable_auto_scaling = true
        node_count          = "1"
        min_count           = "1"
        max_count           = "3"
      }
      # api_server_access_profile = {
      #   vnet_integration_enabled = false
      #   authorized_ip_ranges     = local.net_acls.owner.ip_rules
      # }
      identity = {
        type = "SystemAssigned"
      }
    }
  }

  #Azure Role Assignment
  role_assignment_params = {
    "az_aks_cluster_admin_group" = {
      scope                = module.infra.aks_id[local.aks_conf.internal_aks.name]
      role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
      principal_id         = local.owners
    }
    "az_aks_cluster_admin_sp" = {
      scope                = module.infra.aks_id[local.aks_conf.internal_aks.name]
      role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
      principal_id         = data.azurerm_key_vault_secret.object_id.value
    }
  }

  #Azure Private DNS 
  private_dns_zone_conf = {
    "mysql" = {
      name = "private.mysql.database.azure.com"
    }
  }

  #MySQL Flexible Server
  mysql_conf = {
    "internal_mysql" = {
      name                  = "${local.env_name}-ptae-mysql"
      private_dns_zone_name = local.private_dns_zone_conf.mysql.name
      vnet_id               = module.infra.virtual_network_id
      mysql_admin_password  = random_password.mysql_admin_password.result
      backup_retention_days = 30
      delegated_subnet_id   = module.infra.subnet_id[local.subnet_cidr.mysql_cidr_blocks.subnet_name]
      private_dns_zone_id   = module.infra.private_dns_id[local.private_dns_zone_conf.mysql.name]
      sku_name              = "B_Standard_B2s"
      zone                  = 1
      storage = {
        size_gb = 100
      }
    }
  }

  #TAGS
  tags = {
    managed_by = "Terraform"
  }
}

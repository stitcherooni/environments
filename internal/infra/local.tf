locals {
  #Main
  tenant_id       = "ff9085aa-053a-4b01-8817-effac5fdfdce"
  subscription_id = "31ee4a72-709d-4b02-bd0e-30b59dee8a4c"
  owners          = "65e0258d-d870-4255-9835-4e7d3030e48b" #Owners AzureAD Group
  location        = "uksouth"
  env_name        = "internal"
  dns_zone_name   = "pta-events.com"
  namespace       = {
    dev = "dev",
    qa  = "qa",
  }

  #VNet
  address_space = ["10.10.0.0/19"]

  #Subnet
  cidr_block         = element(local.address_space, 0)
  subnet_cidr_blocks = [for cidr_block in cidrsubnets(local.cidr_block, 3, 9, 7, 7) : cidr_block]

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
    "bastion_cidr_blocks" = {
      subnet_name       = "AzureBastionSubnet"
      cidr              = element(local.subnet_cidr_blocks, 2)
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegations       = {}
    }
    "service_cidr_blocks" = {
      subnet_name       = "${local.env_name}-ptae-service-subnet"
      cidr              = element(local.subnet_cidr_blocks, 3)
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
        node_count          = "2"
        min_count           = "2"
        max_count           = "4"
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
    "az_aks_acr_integration" = {
      scope                            = data.azurerm_container_registry.azcentralcr.id
      role_definition_name             = "App Compliance Automation Administrator"
      principal_id                     = module.infra.az_kubelet_identity[local.aks_conf.internal_aks.name].0.object_id
      skip_service_principal_aad_check = true
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

  #Azure Bastion Host
  bastion_conf = {
    "internal_bastion_host" = {
      name = "${local.env_name}-ptae-bastion"

      ip_configuration = {
        subnet_id = module.infra.subnet_id[local.subnet_cidr.bastion_cidr_blocks.subnet_name]
        public_ip_address_id = module.infra.bastion_pubip
      }
    }
  }

  #Azure Kubernetes Secret
  secret = {
    "dev_pta_events_com" = {
      type = "kubernetes.io/tls"
      metadata = {
        secret_name = local.dns_zone_name
        namespace   = local.namespace.dev
      }
      secret_data = {
        "tls.crt" = data.azurerm_key_vault_secret.pta_events_com_pem.value
        "tls.key" = data.azurerm_key_vault_secret.pta_events_com_key.value
      }
    }
  }
    
  #TAGS
  tags = {
    managed_by = "Terraform"
  }
}

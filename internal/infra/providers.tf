terraform {
  required_version = "~> 1.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.65.0"
    }
  }

  backend "azurerm" {
    storage_account_name = "tfstateinternalsub01"
    resource_group_name  = "az_central"
    container_name       = "tfstate"
    key                  = "internal.infra.tfstate"
    subscription_id      = "31ee4a72-709d-4b02-bd0e-30b59dee8a4c"
    #use_azuread_auth     = true
  }
}

provider "azurerm" {
  subscription_id = local.subscription_id
  tenant_id       = local.tenant_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

terraform {
  required_version = "~> 1.2"

  required_providers {
    null = {
      source = "hashicorp/null"
      version = "3.2.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }

  backend "azurerm" {
    storage_account_name = "tfstateinternalsub01"
    resource_group_name  = "az_central"
    container_name       = "tfstate"
    key                  = "internal.build.agent.tfstate"
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

provider "kubernetes" {
  host = data.terraform_remote_state.internal_infra.outputs.aks_host
  cluster_ca_certificate = base64decode(data.terraform_remote_state.internal_infra.outputs.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "kubelogin"
    args = [
      "get-token",
      "--login",
      "spn",
      "--environment",
      "AzurePublicCloud",
      "--tenant-id",
      data.terraform_remote_state.internal_infra.outputs.tenant_id,
      "--server-id",
      data.terraform_remote_state.internal_infra.outputs.server_id,
      "--client-id",
      data.azurerm_key_vault_secret.client_id.value,
      "--client-secret",
      data.azurerm_key_vault_secret.client_secret.value,
    ]
  }
}
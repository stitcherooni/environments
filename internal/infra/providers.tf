terraform {
  required_version = "~> 1.2"

  required_providers {
    null = {
      source = "hashicorp/null"
      version = "3.2.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.66.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
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

provider "helm" {
  kubernetes {
    host = module.infra.az_kube_config[local.aks_conf.internal_aks.name].0.host
    cluster_ca_certificate = base64decode(module.infra.az_kube_config[local.aks_conf.internal_aks.name].0.cluster_ca_certificate)
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
        "${yamldecode(module.infra.aks["internal-ptae-aks-01"].kube_config_raw).users[0].user.exec.args[8]}",
        "--server-id",
        "${yamldecode(module.infra.aks["internal-ptae-aks-01"].kube_config_raw).users[0].user.exec.args[4]}",
        "--client-id",
        data.azurerm_key_vault_secret.client_id.value,
        "--client-secret",
        data.azurerm_key_vault_secret.client_secret.value,
      ]
    }
  }  
}

provider "kubernetes" {
  host = module.infra.az_kube_config[local.aks_conf.internal_aks.name].0.host
  cluster_ca_certificate = base64decode(module.infra.az_kube_config[local.aks_conf.internal_aks.name].0.cluster_ca_certificate)
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
      "${yamldecode(module.infra.aks["internal-ptae-aks-01"].kube_config_raw).users[0].user.exec.args[8]}",
      "--server-id",
      "${yamldecode(module.infra.aks["internal-ptae-aks-01"].kube_config_raw).users[0].user.exec.args[4]}",
      "--client-id",
      data.azurerm_key_vault_secret.client_id.value,
      "--client-secret",
      data.azurerm_key_vault_secret.client_secret.value,
    ]
  }
}
#Internal infra data
data "terraform_remote_state" "internal_infra" {
  backend = "azurerm"
  config = {
    resource_group_name  = "az_central"
    storage_account_name = "tfstateinternalsub01"
    container_name       = "tfstate"
    key                  = "internal.infra.tfstate"
    subscription_id      = "31ee4a72-709d-4b02-bd0e-30b59dee8a4c"
  }
}

#Azure central Key Vault
data "azurerm_key_vault" "central" {
  name                = "central-kv-01"
  resource_group_name = "az_central"
}
data "azurerm_key_vault_secret" "client_id" {
  key_vault_id = data.azurerm_key_vault.central.id
  name = "internal-adm-sp-client-id"
}
data "azurerm_key_vault_secret" "client_secret" {
  key_vault_id = data.azurerm_key_vault.central.id
  name = "internal-adm-sp-pwd-01"
}
data "azurerm_key_vault_secret" "object_id" {
  key_vault_id = data.azurerm_key_vault.central.id
  name = "internal-adm-sp-obj-id"
}
data "azurerm_key_vault_secret" "azp_token" {
  key_vault_id = data.azurerm_key_vault.central.id
  name = "azp-token"
}
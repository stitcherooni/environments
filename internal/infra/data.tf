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

#Get data with SSL pem and key from key-vault
data "azurerm_key_vault_secret" "pta_events_com_crt" {
  name         = "star-pta-events-com"
  key_vault_id = data.azurerm_key_vault.central.id
}
data "azurerm_key_vault_secret" "pta_events_com_key" {
  name         = "pta-events-com-key"
  key_vault_id = data.azurerm_key_vault.central.id
}

#Azure ACR
data "azurerm_container_registry" "azcentralcr" {
  name                = "azcentralcr"
  resource_group_name = "az_central"
}
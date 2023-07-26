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
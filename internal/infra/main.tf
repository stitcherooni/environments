#MySQL Password
resource "random_password" "mysql_admin_password" {
  length  = 16
  special = false
}

#Create MySQL database
resource "azurerm_mysql_flexible_database" "ptaevent_dev" {
  name                = "ptaevent_dev"
  resource_group_name = module.infra.resource_group_name
  server_name         = local.mysql_conf.internal_mysql.name
  charset             = "latin1"
  collation           = "latin1_swedish_ci"
}

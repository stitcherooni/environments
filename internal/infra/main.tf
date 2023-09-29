#MySQL Password
resource "random_password" "mysql_admin_password" {
  length  = 16
  special = false
}

#Create MySQL dev database
resource "azurerm_mysql_flexible_database" "ptaevent_dev" {
  name                = "ptaevent_dev"
  resource_group_name = module.infra.resource_group_name
  server_name         = local.mysql_conf.internal_mysql.name
  charset             = "latin1"
  collation           = "latin1_swedish_ci"
}

#Create MySQL qa database
resource "azurerm_mysql_flexible_database" "ptaevent_qa" {
  name                = "ptaevent_qa"
  resource_group_name = module.infra.resource_group_name
  server_name         = local.mysql_conf.internal_mysql.name
  charset             = "latin1"
  collation           = "latin1_swedish_ci"
}

#Create dev Namespace
resource "kubernetes_namespace_v1" "dev" {
  metadata {
    name = "dev"
  }
}

#Create qa Namespace
resource "kubernetes_namespace_v1" "qa" {
  metadata {
    name = "qa"
  }
}
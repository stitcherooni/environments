#MySQL Password
resource "random_password" "mysql_admin_password" {
  length  = 16
  special = false
}

resource "azurerm_resource_group" "rg" {
  name = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.k8s_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name           = "agentpool"
    node_count     = var.agent_count
    vm_size        = "Standard_B2s"
    vnet_subnet_id = azurerm_subnet.subnet.id
  }

  tags = {
    Environment = "dev"
  }

}
resource "azurerm_postgresql_server" "tifpostgres" {
  name                = "sonarqube-postgres"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name = "B_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = var.username
  administrator_login_password = var.password
  version                      = "11"
  ssl_enforcement_enabled      = false
}

resource "azurerm_postgresql_database" "tifpostgres" {
  name                = "sonarqube"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.tifpostgres.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_configuration" "tifpostgres" {
  name                = "backslash_quote"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.tifpostgres.name
  value               = "on"
}
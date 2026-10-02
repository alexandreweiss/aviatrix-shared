resource "azurerm_resource_group" "rg" {
  location = var.azure_r1_location
  name     = "${var.azure_r1_location_short}-loga-rg"

}

resource "azurerm_log_analytics_workspace" "logaw" {
  location            = var.azure_r1_location
  name                = "${var.azure_r1_location_short}-loga-ws"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_storage_account" "logawesa" {
  name                     = "logalabwesa"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.azure_r1_location
  account_tier             = "Standard"
  account_kind             = "BlobStorage"
  account_replication_type = "LRS"
}

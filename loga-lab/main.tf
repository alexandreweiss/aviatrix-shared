resource "azurerm_resource_group" "rg" {
  location = var.azure_r1_location
  name     = "${var.azure_r1_location_short}-loga-rg"

}

resource "azurerm_log_analytics_workspace" "logaw" {
  location            = var.azure_r1_location
  name                = "${var.azure_r1_location_short}-loga-ws"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Free"
  retention_in_days   = 7
}



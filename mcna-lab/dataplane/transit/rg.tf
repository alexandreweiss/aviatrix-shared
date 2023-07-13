resource "azurerm_resource_group" "azr-transit-r1-0-rg" {
  location = var.azure_r1_location
  name     = "azr-transit-${var.azure_r1_location_short}-0-rg"
}

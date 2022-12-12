provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "avx-core" {
  location = "West Europe"
  name = "avx-core-rg"
}
resource "azurerm_storage_account" "aviatrixbck00" {
  name = "aviatrixbck00"
  account_tier = "Standard"
  account_replication_type = "LRS"
  location = azurerm_resource_group.avx-core.location
  resource_group_name = azurerm_resource_group.avx-core.name
}

resource "azurerm_storage_container" "aviatrix-backup" {
  name = "aviatrix-backup"
  storage_account_name = azurerm_storage_account.aviatrixbck00.name
}
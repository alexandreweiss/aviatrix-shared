resource "azurerm_resource_group" "vnet_flowl_lab_rg" {
  location = var.azr_r1_location
  name     = "vnet-flowl-lab-rg"
}

resource "azurerm_storage_account" "vnet_flowl_sa" {
  name                     = "vnetflowlsa${random_integer.random_rg.result}"
  resource_group_name      = azurerm_resource_group.random_rg.name
  location                 = var.azr_r1_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}

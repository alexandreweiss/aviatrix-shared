## First region

## Creation of ARS VNET ARS and FIREWALL
resource "azurerm_virtual_network" "ars-spoke-vn" {
  address_space       = ["10.93.0.0/24"]
  location            = azurerm_resource_group.ars-lab-r1.location
  name                = "ars-spoke-vn"
  resource_group_name = azurerm_resource_group.ars-lab-r1.name
}

resource "azurerm_subnet" "ars-spoke-subnet" {
  address_prefixes     = ["10.93.0.64/27"]
  name                 = "RouteServerSubnet"
  resource_group_name  = azurerm_resource_group.ars-lab-r1.name
  virtual_network_name = azurerm_virtual_network.ars-spoke-vn.name
}

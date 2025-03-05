## First region

## Creation of ARS VNET ARS and FIREWALL
resource "azurerm_virtual_network" "fw-vn" {
  address_space       = ["10.92.0.0/24"]
  location            = azurerm_resource_group.ars-lab-r1.location
  name                = "fw-vn"
  resource_group_name = azurerm_resource_group.ars-lab-r1.name
}

resource "azurerm_subnet" "fw-subnet" {
  address_prefixes     = ["10.92.0.0/27"]
  name                 = "fw-subnet"
  resource_group_name  = azurerm_resource_group.ars-lab-r1.name
  virtual_network_name = azurerm_virtual_network.fw-vn.name
}

resource "azurerm_subnet" "fw-vm-subnet" {
  address_prefixes     = ["10.92.0.32/27"]
  name                 = "fw-vm-subnet"
  resource_group_name  = azurerm_resource_group.ars-lab-r1.name
  virtual_network_name = azurerm_virtual_network.fw-vn.name
}

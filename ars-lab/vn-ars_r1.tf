## First region

## RG Creation
resource "azurerm_resource_group" "ars-lab-r1" {
  location = var.azure_r1_location
  name     = "ars-lab-${var.azure_r1_location_short}"
}

## Creation of ARS VNET ARS and FIREWALL
resource "azurerm_virtual_network" "ars-vn" {
  address_space       = ["10.90.0.0/24"]
  location            = azurerm_resource_group.ars-lab-r1.location
  name                = "ars-vn"
  resource_group_name = azurerm_resource_group.ars-lab-r1.name
}

resource "azurerm_subnet" "gw-subnet" {
  address_prefixes     = ["10.90.0.0/27"]
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.ars-lab-r1.name
  virtual_network_name = azurerm_virtual_network.ars-vn.name
}

resource "azurerm_subnet" "vm-subnet" {
  address_prefixes     = ["10.90.0.32/27"]
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.ars-lab-r1.name
  virtual_network_name = azurerm_virtual_network.ars-vn.name
}

resource "azurerm_subnet" "ars-subnet" {
  address_prefixes     = ["10.90.0.64/27"]
  name                 = "RouteServerSubnet"
  resource_group_name  = azurerm_resource_group.ars-lab-r1.name
  virtual_network_name = azurerm_virtual_network.ars-vn.name
}

## Creation of SPOKE VNET containing Spoke GW
resource "azurerm_virtual_network" "spoke-vn" {
  address_space       = ["10.95.0.0/24"]
  location            = azurerm_resource_group.ars-lab-r1.location
  name                = "spoke-vn"
  resource_group_name = azurerm_resource_group.ars-lab-r1.name
}

resource "azurerm_subnet" "spoke-vm-subnet" {
  address_prefixes     = ["10.95.0.0/28"]
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.ars-lab-r1.name
  virtual_network_name = azurerm_virtual_network.spoke-vn.name
}

## Creation of AVX Transit VNET and peering to HUB VNET (we have a dedicated kind of spoke vnet for ER and ARS that we peer with that Aviatrix Transit vnet)
resource "azurerm_virtual_network" "avx-vn" {
  address_space       = ["10.80.0.0/24"]
  location            = azurerm_resource_group.ars-lab-r1.location
  name                = "avx-vn"
  resource_group_name = azurerm_resource_group.ars-lab-r1.name
}

resource "azurerm_subnet" "avx-gw-subnet" {
  address_prefixes     = ["10.80.0.0/28"]
  name                 = "avx-gw-subnet"
  resource_group_name  = azurerm_resource_group.ars-lab-r1.name
  virtual_network_name = azurerm_virtual_network.avx-vn.name
}

resource "azurerm_subnet" "avx-hagw-subnet" {
  address_prefixes     = ["10.80.0.16/28"]
  name                 = "avx-hagw-subnet"
  resource_group_name  = azurerm_resource_group.ars-lab-r1.name
  virtual_network_name = azurerm_virtual_network.avx-vn.name
}

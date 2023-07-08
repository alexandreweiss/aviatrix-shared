resource "azurerm_resource_group" "rg" {
  name     = "vpn-lab-rg"
  location = var.azure_r1_location
}

resource "azurerm_public_ip" "pip" {
  allocation_method   = "Dynamic"
  location            = var.azure_r1_location
  name                = "vpn-gw-${var.azure_r1_location_short}-pip"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_network" "vnet" {
  address_space       = ["10.199.4.0/24"]
  location            = var.azure_r1_location
  name                = "vpn-lab-vn"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "gw-subnet" {
  address_prefixes     = ["10.199.4.0/28"]
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_virtual_network_gateway" "vpn-gw" {
  name                = "vpn-gw"
  location            = var.azure_r1_location
  resource_group_name = azurerm_resource_group.rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = true
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gw-subnet.id
  }
}

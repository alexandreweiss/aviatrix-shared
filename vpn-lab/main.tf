resource "azurerm_resource_group" "rg" {
  name     = "vpn-lab-rg-${var.workspace_key}"
  location = var.azure_r1_location
}

resource "azurerm_public_ip" "pip" {
  allocation_method   = "Dynamic"
  location            = var.azure_r1_location
  name                = "vpn-gw-${var.azure_r1_location_short}-pip"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_network" "vnet" {
  address_space       = [var.vnet_address_space]
  location            = var.azure_r1_location
  name                = "vpn-lab-vn"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "gw-subnet" {
  address_prefixes     = [cidrsubnet(var.vnet_address_space, 4, 0)]
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_subnet" "vm-subnet" {
  address_prefixes     = [cidrsubnet(var.vnet_address_space, 4, 1)]
  name                 = "vm-subnet"
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

  bgp_settings {
    peering_addresses {
      apipa_addresses = ["169.254.21.1", "169.254.21.5"]
    }
    asn = 65516
  }
  sku = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gw-subnet.id
  }
}

resource "azurerm_local_network_gateway" "lng0" {
  location            = var.azure_r1_location
  name                = "avx-0-lng"
  resource_group_name = azurerm_resource_group.rg.name
  gateway_address     = "20.82.35.102"
  bgp_settings {
    asn                 = 65012
    bgp_peering_address = "169.254.21.2"
  }
}

module "r1-vpn-vm" {
  source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  environment         = "vpn"
  location            = var.azure_r1_location
  location_short      = var.azure_r1_location_short
  index_number        = 01
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.vm-subnet.id
  admin_ssh_key       = var.ssh_public_key
  depends_on = [
  ]
}

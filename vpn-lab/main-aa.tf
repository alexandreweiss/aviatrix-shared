resource "azurerm_resource_group" "rg" {
  name     = "vpn-lab-rg-${var.workspace_key}"
  location = var.azure_r1_location
}

resource "azurerm_public_ip" "pip_0" {
  allocation_method   = "Static"
  location            = var.azure_r1_location
  name                = "vpn-gw-${var.azure_r1_location_short}-pip-0"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  sku_tier            = "Regional"
}

resource "azurerm_public_ip" "pip_1" {
  allocation_method   = "Static"
  location            = var.azure_r1_location
  name                = "vpn-gw-${var.azure_r1_location_short}-pip-1"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  sku_tier            = "Regional"
}

resource "azurerm_virtual_network" "vnet" {
  address_space       = [var.vnet_address_space]
  location            = var.azure_r1_location
  name                = "vpn-lab-vn"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "gw-subnet" {
  address_prefixes     = [cidrsubnet(var.vnet_address_space, 3, 3)]
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

  active_active = true
  enable_bgp    = true
  generation    = "Generation2"

  bgp_settings {
    peering_addresses {
      ip_configuration_name = "vnetGatewayConfig_0"
      apipa_addresses       = ["169.254.21.1", "169.254.21.9"]
    }
    peering_addresses {
      ip_configuration_name = "vnetGatewayConfig_1"
      apipa_addresses       = ["169.254.21.5", "169.254.21.13"]
    }
    asn = 65515
  }
  sku = "VpnGw2"

  ip_configuration {
    name                          = "vnetGatewayConfig_0"
    public_ip_address_id          = azurerm_public_ip.pip_0.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gw-subnet.id
  }

  ip_configuration {
    name                          = "vnetGatewayConfig_1"
    public_ip_address_id          = azurerm_public_ip.pip_1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gw-subnet.id
  }
}

resource "azurerm_local_network_gateway" "lng0" {
  location            = var.azure_r1_location
  name                = "avx-0-lng"
  resource_group_name = azurerm_resource_group.rg.name
  gateway_address     = "20.61.236.53"
  bgp_settings {
    asn                 = 65007
    bgp_peering_address = "169.254.21.2"
  }
}

resource "azurerm_local_network_gateway" "lng1" {
  location            = var.azure_r1_location
  name                = "avx-1-lng"
  resource_group_name = azurerm_resource_group.rg.name
  gateway_address     = "108.142.33.72"
  bgp_settings {
    asn                 = 65007
    bgp_peering_address = "169.254.21.6"
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

# Create an Aviatrix Transit External Device Connection to Azure
resource "aviatrix_transit_external_device_conn" "test" {
  vpc_id            = "vpc-abcd1234"
  connection_name   = "my_conn"
  gw_name           = "transitGw"
  connection_type   = "bgp"
  bgp_local_as_num  = "123"
  bgp_remote_as_num = "345"
  remote_gateway_ip = "172.12.13.14"
}

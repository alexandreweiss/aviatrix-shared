data "dns_a_record_set" "controller_ip" {
  host = var.controller_fqdn
}

resource "azurerm_resource_group" "rg" {
  name     = "vpn-lab-rg-${var.workspace_key}"
  location = var.azure_r1_location
}

resource "azurerm_virtual_network" "vnet" {
  address_space       = [var.vnet_address_space]
  location            = var.azure_r1_location
  name                = "vpn-lab-vn"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "gw-subnet" {
  address_prefixes     = [cidrsubnet(var.vnet_address_space, 4, 0)]
  name                 = "gw-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_subnet" "vm-subnet" {
  address_prefixes     = [cidrsubnet(var.vnet_address_space, 4, 1)]
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
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

resource "aviatrix_gateway" "vpn-gw" {
  account_name = var.azure_account
  cloud_type   = 4
  gw_name      = "vpn-gw-${var.workspace_key}"
  gw_size      = "Standard_B1ms"
  subnet       = azurerm_subnet.gw-subnet.address_prefix
  vpc_id       = azurerm_virtual_network.vnet.id
  vpc_reg      = var.azure_r1_location
  asn
}

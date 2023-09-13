## First region

## RG Creation
resource "azurerm_resource_group" "er-lab" {
  location = var.azure_r1_location
  name     = "er-lab"
}

## Creation of HUB VNET containing ER GW, ARS
resource "azurerm_virtual_network" "er-vn" {
  address_space       = ["10.90.0.0/24"]
  location            = azurerm_resource_group.er-lab.location
  name                = "er-vn"
  resource_group_name = azurerm_resource_group.er-lab.name
}

resource "azurerm_subnet" "gw-subnet" {
  address_prefixes     = ["10.90.0.0/27"]
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.er-lab.name
  virtual_network_name = azurerm_virtual_network.er-vn.name
}

resource "azurerm_subnet" "vm-subnet" {
  address_prefixes     = ["10.90.0.32/28"]
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.er-lab.name
  virtual_network_name = azurerm_virtual_network.er-vn.name
}

resource "azurerm_subnet" "ars-subnet" {
  address_prefixes     = ["10.90.0.64/27"]
  name                 = "RouteServerSubnet"
  resource_group_name  = azurerm_resource_group.er-lab.name
  virtual_network_name = azurerm_virtual_network.er-vn.name
}

## Creation of SPOKE VNET containing Spoke GW
resource "azurerm_virtual_network" "spoke-vn" {
  address_space       = ["10.95.0.0/24"]
  location            = azurerm_resource_group.er-lab.location
  name                = "spoke-vn"
  resource_group_name = azurerm_resource_group.er-lab.name
}

resource "azurerm_subnet" "avx-spoke-gw-subnet" {
  address_prefixes     = ["10.95.0.0/28"]
  name                 = "avx-gw-subnet"
  resource_group_name  = azurerm_resource_group.er-lab.name
  virtual_network_name = azurerm_virtual_network.spoke-vn.name
}

## Creation of ER GW
# module "er-gw" {
#   source = "github.com/alexandreweiss/misc-tf-modules.git/er-gateway"

#   resource_group_name = azurerm_resource_group.er-lab.name
#   location            = azurerm_resource_group.er-lab.location
#   gateway_name        = "er-${var.azure_r1_location_short}-gw"
#   gw_subnet_id        = azurerm_subnet.gw-subnet.id
#   gw_sku              = "Standard"
# }

## Creation of AVX Transit VNET and peering to HUB VNET
resource "azurerm_virtual_network" "avx-vn" {
  address_space       = ["10.80.0.0/24"]
  location            = azurerm_resource_group.er-lab.location
  name                = "avx-vn"
  resource_group_name = azurerm_resource_group.er-lab.name
}

resource "azurerm_subnet" "avx-gw-subnet" {
  address_prefixes     = ["10.80.0.0/28"]
  name                 = "avx-gw-subnet"
  resource_group_name  = azurerm_resource_group.er-lab.name
  virtual_network_name = azurerm_virtual_network.avx-vn.name
}

module "vn-peering" {
  source = "github.com/alexandreweiss/terraform-azurerm-vnetpeering"

  left_vnet_resource_group_name  = azurerm_resource_group.er-lab.name
  left_vnet_name                 = azurerm_virtual_network.er-vn.name
  right_vnet_resource_group_name = azurerm_resource_group.er-lab.name
  right_vnet_name                = azurerm_virtual_network.avx-vn.name

  depends_on = [
    azurerm_virtual_network.avx-vn,
    azurerm_virtual_network.er-vn
  ]
}

## ER GW connection to ER Circuit
## THIS ONE MUST BE COMMENTED OUT IF ER CIRCUIT IS UNDEFINIED
# resource "azurerm_virtual_network_gateway_connection" "cr-gw-connection" {
#   name                = "er-connection-${var.azure_r1_location_short}"
#   location            = azurerm_resource_group.er-lab.location
#   resource_group_name = azurerm_resource_group.er-lab.name

#   type                       = "ExpressRoute"
#   virtual_network_gateway_id = module.er-gw.er_gateway.id
#   express_route_circuit_id   = module.azr-er-circuit-1.circuit_id
# }

## Test VM
module "r1-vm" {
  source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  environment         = "vm"
  location            = var.azure_r1_location
  location_short      = var.azure_r1_location_short
  index_number        = 01
  resource_group_name = azurerm_resource_group.er-lab.name
  subnet_id           = azurerm_subnet.vm-subnet.id
  admin_ssh_key       = var.ssh_public_key
  depends_on = [
  ]
}

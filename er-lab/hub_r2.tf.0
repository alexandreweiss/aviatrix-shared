## Second region

## RG Creation
resource "azurerm_resource_group" "er-lab-r2" {
  location = var.azure_r2_location
  name     = "er-lab-${var.azure_r2_location_short}"
}

## Creation of HUB VNET containing ER GW, ARS
resource "azurerm_virtual_network" "er-vn-r2" {
  address_space       = ["10.91.0.0/24"]
  location            = azurerm_resource_group.er-lab-r2.location
  name                = "er-vn"
  resource_group_name = azurerm_resource_group.er-lab-r2.name
}

resource "azurerm_subnet" "gw-subnet-r2" {
  address_prefixes     = ["10.91.0.0/27"]
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.er-lab-r2.name
  virtual_network_name = azurerm_virtual_network.er-vn-r2.name
}

resource "azurerm_subnet" "vm-subnet-r2" {
  address_prefixes     = ["10.91.0.32/28"]
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.er-lab-r2.name
  virtual_network_name = azurerm_virtual_network.er-vn-r2.name
}

resource "azurerm_subnet" "ars-subnet-r2" {
  address_prefixes     = ["10.91.0.64/27"]
  name                 = "RouteServerSubnet"
  resource_group_name  = azurerm_resource_group.er-lab-r2.name
  virtual_network_name = azurerm_virtual_network.er-vn-r2.name
}

## Creation of SPOKE VNET containing Spoke GW
resource "azurerm_virtual_network" "spoke-vn-r2" {
  address_space       = ["10.96.0.0/24"]
  location            = azurerm_resource_group.er-lab-r2.location
  name                = "spoke-vn"
  resource_group_name = azurerm_resource_group.er-lab-r2.name
}

resource "azurerm_subnet" "avx-spoke-gw-subnet-r2" {
  address_prefixes     = ["10.96.0.0/28"]
  name                 = "avx-gw-subnet"
  resource_group_name  = azurerm_resource_group.er-lab-r2.name
  virtual_network_name = azurerm_virtual_network.spoke-vn-r2.name
}

## Creation of ER GW
# module "er-gw-r2" {
#   source = "github.com/alexandreweiss/misc-tf-modules.git/er-gateway"

#   resource_group_name = azurerm_resource_group.er-lab-r2.name
#   location            = azurerm_resource_group.er-lab-r2.location
#   gateway_name        = "er-${var.azure_r2_location_short}-gw"
#   gw_subnet_id        = azurerm_subnet.gw-subnet-r2.id
#   gw_sku              = "Standard"
# }

## Creation of AVX Transit VNET and peering to HUB VNET
resource "azurerm_virtual_network" "avx-vn-r2" {
  address_space       = ["10.81.0.0/24"]
  location            = azurerm_resource_group.er-lab-r2.location
  name                = "avx-vn"
  resource_group_name = azurerm_resource_group.er-lab-r2.name
}

resource "azurerm_subnet" "avx-gw-subnet-r2" {
  address_prefixes     = ["10.81.0.0/28"]
  name                 = "avx-gw-subnet"
  resource_group_name  = azurerm_resource_group.er-lab-r2.name
  virtual_network_name = azurerm_virtual_network.avx-vn-r2.name
}

module "vn-peering-r2" {
  source = "github.com/alexandreweiss/terraform-azurerm-vnetpeering"

  left_vnet_resource_group_name  = azurerm_resource_group.er-lab-r2.name
  left_vnet_name                 = azurerm_virtual_network.er-vn-r2.name
  right_vnet_resource_group_name = azurerm_resource_group.er-lab-r2.name
  right_vnet_name                = azurerm_virtual_network.avx-vn-r2.name

  depends_on = [
    azurerm_virtual_network.avx-vn-r2,
    azurerm_virtual_network.er-vn-r2
  ]
}

## ER GW connection to ER Circuit
## THIS ONE MUST BE COMMENTED OUT IF ER CIRCUIT IS UNDEFINIED
# resource "azurerm_virtual_network_gateway_connection" "cr-gw-connection-r2" {
#   name                = "er-connection-${var.azure_r2_location_short}"
#   location            = azurerm_resource_group.er-lab-r2.location
#   resource_group_name = azurerm_resource_group.er-lab-r2.name

#   type                       = "ExpressRoute"
#   virtual_network_gateway_id = module.er-gw-r2.er_gateway.id
#   express_route_circuit_id   = module.azr-er-circuit-1.circuit_id
# }

## Test VM
module "r2-vm" {
  source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  environment         = "vm"
  location            = var.azure_r2_location
  location_short      = var.azure_r2_location_short
  index_number        = 01
  resource_group_name = azurerm_resource_group.er-lab-r2.name
  subnet_id           = azurerm_subnet.vm-subnet-r2.id
  admin_ssh_key       = var.ssh_public_key
  depends_on = [
  ]
}

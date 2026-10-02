## First region

## Creation of HUB VNET containing ER GW, ARS
resource "azurerm_virtual_network" "er-vn" {
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.mp_lab_r1.location
  name                = "er-${random_integer.random.result}-vn"
  resource_group_name = azurerm_resource_group.mp_lab_r1.name
}

resource "azurerm_subnet" "gw-subnet" {
  address_prefixes     = [cidrsubnet(var.vnet_address_space, 3, 0)]
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.mp_lab_r1.name
  virtual_network_name = azurerm_virtual_network.er-vn.name
}

resource "azurerm_subnet" "vm-subnet" {
  address_prefixes     = [cidrsubnet(var.vnet_address_space, 4, 4)]
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.mp_lab_r1.name
  virtual_network_name = azurerm_virtual_network.er-vn.name
}

resource "azurerm_subnet" "ars-subnet" {
  address_prefixes     = [cidrsubnet(var.vnet_address_space, 2, 2)]
  name                 = "RouteServerSubnet"
  resource_group_name  = azurerm_resource_group.mp_lab_r1.name
  virtual_network_name = azurerm_virtual_network.er-vn.name
}

## Creation of ER GW
module "er-gw" {
  source = "github.com/alexandreweiss/misc-tf-modules.git/er-gateway"

  resource_group_name = azurerm_resource_group.mp_lab_r1.name
  location            = azurerm_resource_group.mp_lab_r1.location
  gateway_name        = "er-${random_integer.random.result}-${var.azure_r1_location_short}-gw"
  gw_subnet_id        = azurerm_subnet.gw-subnet.id
  gw_sku              = "Standard"
}

## ER GW connection to ER Circuit
## THIS ONE MUST BE COMMENTED OUT IF ER CIRCUIT IS UNDEFINIED

resource "azurerm_virtual_network_gateway_connection" "cr-gw-connection" {
  # name = "er-connection-${var.azure_r1_location_short}"
  name                = "er-connection-${var.azure_r1_location_short}"
  location            = azurerm_resource_group.mp_lab_r1.location
  resource_group_name = azurerm_resource_group.mp_lab_r1.name

  type                       = "ExpressRoute"
  virtual_network_gateway_id = module.er-gw.er_gateway.id
  express_route_circuit_id   = module.azr_er_circuit_1.circuit_id
}

## Test VM
module "r1-vm" {
  source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  environment         = "vm"
  location            = azurerm_resource_group.mp_lab_r1.location
  location_short      = var.azure_r1_location_short
  index_number        = 01
  resource_group_name = azurerm_resource_group.mp_lab_r1.name
  subnet_id           = azurerm_subnet.vm-subnet.id
  admin_ssh_key       = var.ssh_public_key
  enable_public_ip    = true
  depends_on = [
  ]
}

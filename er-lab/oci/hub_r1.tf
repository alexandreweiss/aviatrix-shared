## First region

## RG Creation
resource "azurerm_resource_group" "oci-lab-r1" {
  location = var.azure_r1_location
  name     = "oci-lab-${var.azure_r1_location_short}"
}

## Azure Express Route Circuit creation (Azure Side)
module "azr-er-circuit-1" {
  source = "github.com/alexandreweiss/misc-tf-modules/er-circuit"
  count  = var.deploy_er_circuit ? 1 : 0

  circuit_name          = "er-oci-fra"
  peering_location      = "Frankfurt"
  location              = azurerm_resource_group.oci-lab-r1.location
  resource_group_name   = azurerm_resource_group.oci-lab-r1.name
  circuit_bandwidth     = "1000"
  service_provider_name = "Oracle Cloud Fastconnect"
}

## Creation of HUB VNET containing ER GW, ARS
resource "azurerm_virtual_network" "er-vn" {
  address_space       = ["10.90.0.0/24"]
  location            = azurerm_resource_group.oci-lab-r1.location
  name                = "er-vn"
  resource_group_name = azurerm_resource_group.oci-lab-r1.name
}

resource "azurerm_subnet" "gw-subnet" {
  address_prefixes     = ["10.90.0.0/27"]
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.oci-lab-r1.name
  virtual_network_name = azurerm_virtual_network.er-vn.name
}

resource "azurerm_subnet" "vm-subnet" {
  address_prefixes     = ["10.90.0.32/28"]
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.oci-lab-r1.name
  virtual_network_name = azurerm_virtual_network.er-vn.name
}

resource "azurerm_subnet" "ars-subnet" {
  address_prefixes     = ["10.90.0.64/27"]
  name                 = "RouteServerSubnet"
  resource_group_name  = azurerm_resource_group.oci-lab-r1.name
  virtual_network_name = azurerm_virtual_network.er-vn.name
}

## Creation of ER GW
module "er-gw" {
  source = "github.com/alexandreweiss/misc-tf-modules.git/er-gateway"

  resource_group_name = azurerm_resource_group.oci-lab-r1.name
  location            = azurerm_resource_group.oci-lab-r1.location
  gateway_name        = "er-${var.azure_r1_location_short}-gw"
  gw_subnet_id        = azurerm_subnet.gw-subnet.id
  gw_sku              = "Standard"
}

## ER GW connection to ER Circuit
## THIS ONE MUST BE COMMENTED OUT IF ER CIRCUIT IS UNDEFINIED
resource "azurerm_virtual_network_gateway_connection" "cr-gw-connection" {
  count = var.deploy_er_connection ? 1 : 0

  name                = "er-connection-${var.azure_r1_location_short}"
  location            = azurerm_resource_group.oci-lab-r1.location
  resource_group_name = azurerm_resource_group.oci-lab-r1.name

  type                       = "ExpressRoute"
  virtual_network_gateway_id = module.er-gw.er_gateway.id
  express_route_circuit_id   = module.azr-er-circuit-1[0].circuit_id
}

# Test VM
module "r1-vm" {
  source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  environment         = "vm"
  location            = var.azure_r1_location
  location_short      = var.azure_r1_location_short
  index_number        = 01
  resource_group_name = azurerm_resource_group.oci-lab-r1.name
  subnet_id           = azurerm_subnet.vm-subnet.id
  admin_ssh_key       = var.ssh_public_key
  depends_on = [
  ]
}

# resource "oci_core_virtual_circuit" "oci-vc" {
#   compartment_id = var.oci_comp_id
#   type = "PRIVATE"
#   bandwidth_shape_name = "1 Gbps"
#   cross_connect_mappings {
#     customer_bgp_asn = 12076
#     oracle_bgp_asn = 31898
#     customer_bgp_peering_ip = "192.168.111.2/30"


# }

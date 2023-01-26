resource "azurerm_resource_group" "er-lab" {
  location = "eastus2"
  name     = "er-lab"
}

resource "packetfabric_cs_azure_hosted_connection" "er-circuit" {
  provider          = packetfabric
  account_uuid      = var.packet_fabric_account_id
  description       = "Azure ER Circuit"
  azure_service_key = module.er-circuit-pf.service_key
  port              = var.packet_fabric_router_port
  vlan_private      = var.private_peering_vlan_id
  speed             = "50Mbps"
}

resource "packetfabric_cloud_router_connection_azure" "crc4" {
  provider          = packetfabric
  account_uuid      = var.packet_fabric_account_id
  description       = "ER Circuit connection"
  circuit_id        = packetfabric_cs_azure_hosted_connection.er-circuit.id
  azure_service_key = module.er-circuit-pf.service_key
  speed             = "50Mbps"
  is_public         = false
}

module "er-circuit-pf" {
  source = "github.com/alexandreweiss/misc-tf-modules/er-circuit"

  circuit_name        = "er-pf-newyork"
  peering_location    = "New York"
  location            = azurerm_resource_group.er-lab.location
  resource_group_name = azurerm_resource_group.er-lab.name
}

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

module "er-gw" {
  source = "github.com/alexandreweiss/misc-tf-modules.git/er-gateway"

  resource_group_name = azurerm_resource_group.er-lab.name
  location            = azurerm_resource_group.er-lab.location
  gateway_name        = "er-gw"
  gw_subnet_id        = azurerm_subnet.gw-subnet.id
  gateway_sku         = "Standard"
}

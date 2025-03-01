## First region

## Creation of ARS VNET ARS and FIREWALL
resource "azurerm_virtual_network" "fw-vn" {
  address_space       = ["10.92.0.0/24"]
  location            = azurerm_resource_group.ars-lab-r1.location
  name                = "fw-vn"
  resource_group_name = azurerm_resource_group.ars-lab-r1.name
}

resource "azurerm_subnet" "fw-subnet" {
  address_prefixes     = ["10.92.0.0/27"]
  name                 = "fw-subnet"
  resource_group_name  = azurerm_resource_group.ars-lab-r1.name
  virtual_network_name = azurerm_virtual_network.fw-vn.name
}

resource "azurerm_subnet" "fw-vm-subnet" {
  address_prefixes     = ["10.92.0.32/27"]
  name                 = "fw-vm-subnet"
  resource_group_name  = azurerm_resource_group.ars-lab-r1.name
  virtual_network_name = azurerm_virtual_network.fw-vn.name
}
module "fw-transit-vn-peering" {
  source = "github.com/alexandreweiss/terraform-azurerm-vnetpeering"

  left_vnet_resource_group_name  = azurerm_resource_group.ars-lab-r1.name
  left_vnet_name                 = azurerm_virtual_network.fw-vn.name
  right_vnet_resource_group_name = azurerm_resource_group.ars-lab-r1.name
  right_vnet_name                = module.azure_transit_ars.vpc.name
  allow_forwarded_traffic        = true

  depends_on = [
    azurerm_virtual_network.fw-vn,
    module.azure_transit_ars
  ]
}

module "fw-ars-vn-peering" {
  source = "github.com/alexandreweiss/terraform-azurerm-vnetpeering"

  left_vnet_resource_group_name  = azurerm_resource_group.ars-lab-r1.name
  left_vnet_name                 = azurerm_virtual_network.fw-vn.name
  right_vnet_resource_group_name = azurerm_resource_group.ars-lab-r1.name
  right_vnet_name                = azurerm_virtual_network.ars-vn.name
  allow_forwarded_traffic        = true
  left_allow_gateway_transit     = false
  left_use_remote_gateways       = true
  right_allow_gateway_transit    = true
  right_use_remote_gateways      = false


  depends_on = [
    azurerm_virtual_network.ars-vn,
    azurerm_virtual_network.spoke-vn
  ]
}

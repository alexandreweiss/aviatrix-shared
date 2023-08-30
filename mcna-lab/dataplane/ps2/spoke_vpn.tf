// SPOKE VPN
resource "azurerm_resource_group" "azr-r1-spoke-vpn-rg" {
  location = var.azure_r1_location
  name     = "azr-${var.azure_r1_location_short}-spoke-vpn-rg"
}

resource "azurerm_virtual_network" "azr-r1-spoke-vpn" {
  address_space       = ["10.10.3.0/24"]
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-vpn-vn"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-vpn-rg.name
}

resource "azurerm_subnet" "azr-r1-spoke-vpn-gw-subnet" {
  address_prefixes     = ["10.10.3.0/28"]
  name                 = "avx-gw-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-vpn-rg.name
  virtual_network_name = azurerm_virtual_network.azr-r1-spoke-vpn.name
}

resource "azurerm_subnet" "azr-r1-spoke-vpn-hagw-subnet" {
  address_prefixes     = ["10.10.3.16/28"]
  name                 = "avx-hagw-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-vpn-rg.name
  virtual_network_name = azurerm_virtual_network.azr-r1-spoke-vpn.name
}

resource "azurerm_subnet" "azr-r1-spoke-vpn-vm-subnet" {
  address_prefixes     = ["10.10.3.32/28"]
  name                 = "avx-vm-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-vpn-rg.name
  virtual_network_name = azurerm_virtual_network.azr-r1-spoke-vpn.name
}

module "azr_r1_spoke_vpn" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.6.1"

  cloud            = "Azure"
  name             = "${var.azure_r1_location_short}-spoke-vpn"
  vpc_id           = "${azurerm_virtual_network.azr-r1-spoke-vpn.name}:${azurerm_resource_group.azr-r1-spoke-vpn-rg.name}:${azurerm_virtual_network.azr-r1-spoke-vpn.guid}"
  gw_subnet        = azurerm_subnet.azr-r1-spoke-vpn-gw-subnet.address_prefixes[0]
  use_existing_vpc = true
  region           = var.azure_r1_location
  account          = var.azure_account
  transit_gw       = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name
  ha_gw            = false
  single_az_ha     = false
  //network_domain   = aviatrix_segmentation_network_domain.vpn_nd.domain_name
  resource_group = azurerm_resource_group.azr-r1-spoke-vpn-rg.name
}

resource "aviatrix_gateway" "we-vpn-0" {

  cloud_type       = 8
  account_name     = var.azure_account
  gw_name          = "${var.azure_r1_location_short}-vpn-0"
  vpc_id           = "${azurerm_virtual_network.azr-r1-spoke-vpn.name}:${azurerm_resource_group.azr-r1-spoke-vpn-rg.name}:${azurerm_virtual_network.azr-r1-spoke-vpn.guid}"
  vpc_reg          = var.azure_r1_location
  gw_size          = "Standard_B1ms"
  subnet           = "10.10.3.16/28"
  zone             = "az-1"
  vpn_access       = true
  vpn_cidr         = "172.20.20.0/24"
  additional_cidrs = var.p2s_additional_cidrs
  max_vpn_conn     = "100"
  split_tunnel     = true


  depends_on = [
    module.azr_r1_spoke_vpn
  ]
}

// Peering to controller for internal management

module "controller-vpn-spoke-peering" {
  source = "github.com/alexandreweiss/terraform-azurerm-vnetpeering"

  left_vnet_resource_group_name  = azurerm_resource_group.azr-r1-spoke-vpn-rg.name
  left_vnet_name                 = azurerm_virtual_network.azr-r1-spoke-vpn.name
  right_vnet_resource_group_name = local.controller.controller_resource_group_name
  right_vnet_name                = local.controller.controller_vnet_name

  depends_on = [
    azurerm_virtual_network.azr-r1-spoke-vpn
  ]
}

// User VPN
resource "aviatrix_vpn_user" "aweiss" {

  user_email = "aweiss@aviatrix.com"
  user_name  = "aweiss"
  gw_name    = aviatrix_gateway.we-vpn-0.gw_name
  vpc_id     = module.azr_r1_spoke_vpn.spoke_gateway.vpc_id
  //gw_name    = aviatrix_gateway.we-vpn-0[0].gw_name
  //vpc_id     = aviatrix_gateway.we-vpn-0[0].vpc_id

  depends_on = [aviatrix_gateway.we-vpn-0]
}

output "spoke_vpn" {
  value     = module.azr_r1_spoke_vpn
  sensitive = true
}

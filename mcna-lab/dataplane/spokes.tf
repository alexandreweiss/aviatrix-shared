module "we_spoke_prd" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  //version = "1.4.2"
  count = local.features.deploy_azr_we_spoke_prd ? 1 : 0

  cloud           = "Azure"
  name            = "we-spoke-prd"
  cidr            = "10.10.1.0/24"
  region          = var.azure_we_location
  account         = local.accounts.azure_account
  transit_gw      = module.azure_transit_we.transit_gateway.gw_name
  network_domain  = aviatrix_segmentation_network_domain.prd_nd.domain_name
  ha_gw = true
}

module "we_spoke_dev" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  //version = "1.4.2"
  count = local.features.deploy_azr_we_spoke_dev ? 1 : 0

  cloud           = "Azure"
  name            = "we-spoke-dev"
  cidr            = "10.10.2.0/24"
  region          = var.azure_we_location
  account         = local.accounts.azure_account
  transit_gw      = module.azure_transit_we.transit_gateway.gw_name
  ha_gw           = false
  network_domain  = aviatrix_segmentation_network_domain.dev_nd.domain_name
  single_ip_snat  = true
}

module "we_spoke_vpn" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  //version = "1.4.2"
  count = local.features.deploy_azr_vpn_spoke ? 1 : 0

  cloud           = "Azure"
  name            = "we-spoke-vpn"
  cidr            = "10.10.3.0/24"
  region          = var.azure_we_location
  account         = local.accounts.azure_account
  transit_gw      = module.azure_transit_we.transit_gateway.gw_name
  ha_gw           = false
  network_domain  = aviatrix_segmentation_network_domain.vpn_nd.domain_name
}

resource "aviatrix_gateway" "we-vpn-0" {
  count = local.features.deploy_azr_vpn_gw && local.features.deploy_azr_vpn_spoke ? 1 : 0

  cloud_type   = 8
  account_name = local.accounts.azure_account
  gw_name      = "we-vpn-0"
  vpc_id       = module.we_spoke_vpn[0].vpc.vpc_id
  vpc_reg      = var.azure_we_location
  gw_size      = "Standard_B1ms"
  subnet       = "10.10.3.16/28"
  zone         = "az-1"
  vpn_access   = true
  vpn_cidr     = "172.20.20.0/24"
  additional_cidrs = var.p2s_additional_cidrs
  max_vpn_conn = "100"  

  depends_on = [
    module.we_spoke_vpn
  ]
}

// Peering to controller for internal management

data "aviatrix_vpc" "we_spoke_vpn" {
  name = module.we_spoke_vpn[0].vpc.name
  depends_on = [
    module.we_spoke_vpn
  ]
}

module "controller-vpn-spoke-peering" {
  source  = "github.com/alexandreweiss/terraform-azurerm-vnetpeering"
  count   = local.features.deploy_azr_vpn_spoke ? 1 : 0

  left_vnet_resource_group_name = data.aviatrix_vpc.we_spoke_vpn.resource_group
  left_vnet_name = data.aviatrix_vpc.we_spoke_vpn.name
  right_vnet_resource_group_name = local.controller.controller_resource_group_name
  right_vnet_name = local.controller.controller_vnet_name
}

module "ne_spoke_prd" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  //version = "1.4.2"
  count = local.features.deploy_azr_ne_spoke ? 1 : 0

  cloud           = "Azure"
  name            = "ne-spoke-prd"
  cidr            = "10.20.1.0/24"
  region          = var.azure_ne_location
  account         = local.accounts.azure_account
  transit_gw      = module.azure_transit_ne.transit_gateway.gw_name
  //network_domain  = aviatrix_segmentation_network_domain.prd_nd.domain_name
}

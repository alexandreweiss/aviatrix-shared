module "azure_transit_ars" {
  source = "terraform-aviatrix-modules/mc-transit/aviatrix"
  //version = "2.5.1"

  cloud                         = "azure"
  region                        = var.azure_r1_location
  cidr                          = "10.110.0.0/23"
  account                       = var.azure_account
  name                          = "azr-${var.azure_r1_location_short}-ars-transit"
  local_as_number               = 65014
  resource_group                = azurerm_resource_group.er-lab-r1.name
  bgp_lan_interfaces_count      = 1
  enable_bgp_over_lan           = true
  instance_size                 = "Standard_B2ms"
  insane_mode                   = true
  enable_advertise_transit_cidr = true
}

# This is the BGP over LAN connection creation on Aviatrix side
resource "aviatrix_spoke_external_device_conn" "transit-sdwan-bgp" {
  vpc_id                    = module.azure_transit_ars.vpc.vpc_id
  connection_name           = "ars"
  gw_name                   = module.azure_transit_ars.transit_gateway.gw_name
  connection_type           = "bgp"
  tunnel_protocol           = "LAN"
  bgp_local_as_num          = "65014"
  bgp_remote_as_num         = "65515"
  remote_lan_ip             = "10.90.0.69"
  local_lan_ip              = module.azure_transit_ars.transit_gateway.bgp_lan_ip_list[0]
  remote_vpc_name           = "${azurerm_virtual_network.er-vn.name}:${azurerm_resource_group.er-lab-r1.name}:${data.azurerm_subscription.current.subscription_id}"
  backup_local_lan_ip       = module.azure_transit_ars.transit_gateway.ha_bgp_lan_ip_list[0]
  backup_remote_lan_ip      = "10.90.0.68"
  backup_bgp_remote_as_num  = "65515"
  ha_enabled                = true
  depends_on                = [module.vn-peering]
  enable_bgp_lan_activemesh = true
  //manual_bgp_advertised_cidrs = ["10.0.0.0/16"]
}

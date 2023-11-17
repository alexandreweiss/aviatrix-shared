# Simulated DC
module "dc_ett_router" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.6.6"

  cloud           = "Azure"
  name            = "dc-${var.azure_r1_location_short}-router"
  region          = var.azure_r1_location
  cidr            = "192.168.100.0/24"
  account         = var.azure_account
  attached        = false
  local_as_number = 65016
  enable_bgp      = true
  ha_gw           = false
}

## DC ER backup using IPSEC+BGP over Internet (DC SIDE)
resource "aviatrix_spoke_external_device_conn" "dc_to_azure_transit" {
  vpc_id             = module.dc_ett_router.spoke_gateway.vpc_id
  connection_name    = "ETT_dc_to_azure_transit"
  connection_type    = "bgp"
  tunnel_protocol    = "IPSEC"
  bgp_local_as_num   = "65016"
  bgp_remote_as_num  = "65014"
  remote_gateway_ip  = module.azure_transit_ars.transit_gateway.eip
  local_tunnel_cidr  = "169.254.100.2/30"
  remote_tunnel_cidr = "169.254.100.1/30"
  pre_shared_key     = var.pre_shared_key
  gw_name            = module.dc_ett_router.spoke_gateway.gw_name
}

resource "aviatrix_spoke_external_device_conn" "dc_to_azure_transit_hagw" {
  vpc_id             = module.dc_ett_router.spoke_gateway.vpc_id
  connection_name    = "ETT_dc_to_azure_transit_hagw"
  connection_type    = "bgp"
  tunnel_protocol    = "IPSEC"
  bgp_local_as_num   = "65016"
  bgp_remote_as_num  = "65014"
  remote_gateway_ip  = module.azure_transit_ars.transit_gateway.ha_eip
  local_tunnel_cidr  = "169.254.100.6/30"
  remote_tunnel_cidr = "169.254.100.5/30"
  pre_shared_key     = var.pre_shared_key
  gw_name            = module.dc_ett_router.spoke_gateway.gw_name
}

## DC ER backup using IPSEC+BGP over Internet (TRANSIT SIDE)
resource "aviatrix_transit_external_device_conn" "azure_transit_to_dc" {
  vpc_id             = module.azure_transit_ars.vpc.vpc_id
  connection_name    = "ETT_azure_transit_to_dc"
  connection_type    = "bgp"
  tunnel_protocol    = "IPSEC"
  bgp_local_as_num   = "65014"
  bgp_remote_as_num  = "65016"
  remote_gateway_ip  = module.dc_ett_router.spoke_gateway.eip
  local_tunnel_cidr  = "169.254.100.1/30,169.254.100.5/30"
  remote_tunnel_cidr = "169.254.100.2/30,169.254.100.6/30"
  pre_shared_key     = var.pre_shared_key
  gw_name            = module.azure_transit_ars.transit_gateway.gw_name
}

## DC to COLO
resource "aviatrix_spoke_external_device_conn" "dc_to_colo" {
  vpc_id          = module.dc_ett_router.spoke_gateway.vpc_id
  connection_name = "ETT_dc_to_colo"
  connection_type = "bgp"
  #   custom_algorithms      = false
  #   phase_1_authentication = "SHA-256"
  #   phase_1_dh_groups      = "14"
  #   phase_1_encryption     = "AES-256-CBC"
  #   phase_2_authentication = "HMAC-SHA-256"
  #   phase_2_dh_groups      = "14"
  #   phase_2_encryption     = "AES-256-CBC"
  enable_ikev2       = true
  tunnel_protocol    = "IPSEC"
  bgp_local_as_num   = "65016"
  bgp_remote_as_num  = "64000"
  remote_gateway_ip  = var.packet_fabric_ipsec_ip_address
  local_tunnel_cidr  = "169.254.101.2/30"
  remote_tunnel_cidr = "169.254.101.1/30"
  pre_shared_key     = var.pre_shared_key
  gw_name            = module.dc_ett_router.spoke_gateway.gw_name
}

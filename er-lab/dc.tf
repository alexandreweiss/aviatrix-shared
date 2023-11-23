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
# resource "aviatrix_spoke_external_device_conn" "dc_to_colo" {
#   vpc_id             = module.dc_ett_router.spoke_gateway.vpc_id
#   connection_name    = "ETT_dc_to_colo"
#   connection_type    = "bgp"
#   enable_ikev2       = true
#   tunnel_protocol    = "IPSEC"
#   bgp_local_as_num   = "65016"
#   bgp_remote_as_num  = "64000"
#   remote_gateway_ip  = var.packet_fabric_ipsec_ip_address
#   local_tunnel_cidr  = "169.254.101.2/30"
#   remote_tunnel_cidr = "169.254.101.1/30"
#   pre_shared_key     = var.pre_shared_key
#   gw_name            = module.dc_ett_router.spoke_gateway.gw_name
# }

# Create an Aviatrix Site2cloud Connection
resource "aviatrix_site2cloud" "test_s2c" {
  vpc_id                     = module.dc_ett_router.spoke_gateway.vpc_id
  connection_type            = "unmapped"
  connection_name            = "ETT_dc_to_colo"
  remote_gateway_type        = "generic"
  tunnel_type                = "route"
  primary_cloud_gateway_name = "gw1"
  remote_gateway_ip          = "5.5.5.5"
  remote_subnet_cidr         = "10.23.0.0/24"
  local_subnet_cidr          = "10.20.1.0/24"
}

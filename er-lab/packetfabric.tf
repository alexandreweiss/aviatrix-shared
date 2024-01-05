## PacketFabric side creation

## CR Creation
resource "packetfabric_cloud_router" "cr1" {
  provider     = packetfabric
  account_uuid = var.packet_fabric_account_id
  asn          = 64000
  name         = "aweiss-cr-1"
  capacity     = "100Mbps"
  regions      = ["UK"]
  labels       = ["dev", "aviatrix_user:aweiss"]
}

## Azure Express Route Circuit creation (PF Side)
resource "packetfabric_cloud_router_connection_azure" "cr1-azr-er-circuit-1" {
  provider          = packetfabric
  account_uuid      = var.packet_fabric_account_id
  description       = "cr1ToazrErCircuit1"
  circuit_id        = packetfabric_cloud_router.cr1.id
  azure_service_key = module.azr-er-circuit-1.service_key
  speed             = "50Mbps"
  maybe_nat         = false
  is_public         = false
  labels            = ["dev", "aviatrix_user:aweiss"]
}

## Azure Express Route Circuit creation (Azure Side)
module "azr-er-circuit-1" {
  source = "github.com/alexandreweiss/misc-tf-modules/er-circuit"

  circuit_name        = "er-pf-ams"
  peering_location    = "Amsterdam"
  location            = azurerm_resource_group.er-lab-r1.location
  resource_group_name = azurerm_resource_group.er-lab-r1.name
}

## Azure Express Route Private peering creation
resource "azurerm_express_route_circuit_peering" "private" {
  express_route_circuit_name    = module.azr-er-circuit-1.circuit_name
  peering_type                  = "AzurePrivatePeering"
  resource_group_name           = azurerm_resource_group.er-lab-r1.name
  vlan_id                       = packetfabric_cloud_router_connection_azure.cr1-azr-er-circuit-1.vlan_id_private
  ipv4_enabled                  = true
  primary_peer_address_prefix   = "169.254.247.0/30"
  secondary_peer_address_prefix = "169.254.247.4/30"
  peer_asn                      = 64000

}

## PacketFabric BGP session creation from CR to MSEE
resource "packetfabric_cloud_router_bgp_session" "cr_bgp1" {
  provider      = packetfabric
  circuit_id    = packetfabric_cloud_router.cr1.id
  connection_id = packetfabric_cloud_router_connection_azure.cr1-azr-er-circuit-1.id


  remote_asn = 12076
  prefixes {
    prefix     = "0.0.0.0/0"
    type       = "out" # Allowed Prefixes to Cloud
    match_type = "orlonger"
  }
  prefixes {
    prefix     = "0.0.0.0/0"
    type       = "in" # Allowed Prefixes from Cloud
    match_type = "orlonger"
  }
  primary_subnet = "169.254.247.0/30"
  //secondary_subnet = "169.254.247.4/30"
}

## Connection to DC
# resource "packetfabric_cloud_router_connection_ipsec" "dc_to_colo" {
#   account_uuid                 = var.packet_fabric_account_id
#   provider                     = packetfabric
#   description                  = "DC to Colo CX"
#   circuit_id                   = packetfabric_cloud_router.cr1.id
#   pop                          = "LON1"
#   speed                        = "50Mbps"
#   gateway_address              = module.dc_ett_router.spoke_gateway.eip
#   ike_version                  = 2
#   phase1_authentication_method = "pre-shared-key"
#   phase1_group                 = "group14"
#   phase1_encryption_algo       = "aes-256-cbc"
#   phase1_authentication_algo   = "sha-256"
#   phase1_lifetime              = 10800
#   phase2_pfs_group             = "group14"
#   phase2_encryption_algo       = "aes-256-cbc"
#   phase2_authentication_algo   = "hmac-sha-256-128"
#   phase2_lifetime              = 28800
#   shared_key                   = var.pre_shared_key
#   labels                       = ["aviatrix_user:aweiss", "dev"]
# }

## BGP Connection to DC
## PacketFabric BGP session creation from CR to MSEE
# resource "packetfabric_cloud_router_bgp_session" "cr_bgp_to_dc" {
#   provider      = packetfabric
#   circuit_id    = packetfabric_cloud_router.cr1.id
#   connection_id = packetfabric_cloud_router_connection_ipsec.dc_to_colo.id

#   remote_asn     = 65016
#   remote_address = "169.254.101.2/30"
#   l3_address     = "169.254.101.1/30"

#   prefixes {
#     prefix     = "0.0.0.0/0"
#     type       = "out" # Allowed Prefixes to Cloud
#     match_type = "orlonger"
#   }
#   prefixes {
#     prefix     = "0.0.0.0/0"
#     type       = "in" # Allowed Prefixes from Cloud
#     match_type = "orlonger"
#   }
#   //secondary_subnet = "169.254.247.4/30"
# }

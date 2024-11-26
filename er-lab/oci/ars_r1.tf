## ARS creation in region 1

module "ars_r1" {
  source = "github.com/alexandreweiss/misc-tf-modules.git/ars"
  count  = var.deploy_ars ? 1 : 0

  resource_group_name = azurerm_resource_group.oci-lab-r1.name
  location            = var.azure_r1_location
  subnet_id           = azurerm_subnet.ars-subnet.id
  ars_name            = "ars-${var.azure_r1_location_short}"
  enable_b2b          = true
}

resource "azurerm_route_server_bgp_connection" "avx-gw" {
  count = var.deploy_ars ? 1 : 0

  name            = "we-bgp-transit-gw"
  peer_asn        = 65007
  peer_ip         = "10.10.0.116"
  route_server_id = module.ars_r1[0].ars.id
  depends_on      = [azurerm_route_server_bgp_connection.avx-hagw]
}

resource "azurerm_route_server_bgp_connection" "avx-hagw" {
  count = var.deploy_ars ? 1 : 0

  name            = "we-bgp-transit-hagw"
  peer_asn        = 65007
  peer_ip         = "10.10.0.124"
  route_server_id = module.ars_r1[0].ars.id
}

data "dns_a_record_set" "controller_ip" {
  host = var.controller_fqdn
}

# resource "aviatrix_spoke_external_device_conn" "transit-vwan-bgp" {
#   count = var.deploy_ars ? 1 : 0

#   vpc_id                   = "we-partner-spoke-er-vn:oci-lab-we:344b26e8-234d-4a65-abd7-0242648ca886"
#   connection_name          = "to-spoke"
#   gw_name                  = "we-partner-spoke-er"
#   connection_type          = "bgp"
#   tunnel_protocol          = "LAN"
#   bgp_local_as_num         = "65006"
#   bgp_remote_as_num        = "65515"
#   remote_lan_ip            = "10.90.0.69"
#   local_lan_ip             = "10.10.2.84"
#   remote_vpc_name          = "er-vn:oci-lab-we:cc67e95e-9baa-4ef4-bfac-a33a19ef2232"
#   backup_local_lan_ip      = "10.10.2.92"
#   backup_remote_lan_ip     = "10.90.0.68"
#   backup_bgp_remote_as_num = "65515"
#   ha_enabled               = true
# }

# TRANSIT TO ARS

data "tfe_outputs" "dataplane" {
  organization = "ananableu"
  workspace    = "aviatrix-shared"
}


resource "aviatrix_spoke_external_device_conn" "transit-vwan-bgp" {
  count = var.deploy_ars ? 1 : 0

  vpc_id                    = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.vpc_id
  connection_name           = "to-ars"
  gw_name                   = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name
  connection_type           = "bgp"
  tunnel_protocol           = "LAN"
  bgp_local_as_num          = "65007"
  bgp_remote_as_num         = "65515"
  remote_lan_ip             = "10.90.0.69"
  local_lan_ip              = "10.10.0.116"
  remote_vpc_name           = "er-vn:oci-lab-we:cc67e95e-9baa-4ef4-bfac-a33a19ef2232"
  backup_local_lan_ip       = "10.10.0.124"
  backup_remote_lan_ip      = "10.90.0.68"
  backup_bgp_remote_as_num  = "65515"
  ha_enabled                = true
  enable_bgp_lan_activemesh = true
}

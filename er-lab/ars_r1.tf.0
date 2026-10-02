## ARS creation in region 1

module "ars_r1" {
  source = "github.com/alexandreweiss/misc-tf-modules.git/ars"

  resource_group_name = azurerm_resource_group.er-lab-r1.name
  location            = var.azure_r1_location
  subnet_id           = azurerm_subnet.ars-subnet.id
  ars_name            = "ars-${var.azure_r1_location_short}"
  enable_b2b          = true
}

resource "azurerm_route_server_bgp_connection" "avx-gw" {
  name            = "we-bgp-transit-gw"
  peer_asn        = 65014
  peer_ip         = module.azure_transit_ars.transit_gateway.bgp_lan_ip_list[0]
  route_server_id = module.ars_r1.ars.id
}

resource "azurerm_route_server_bgp_connection" "avx-hagw" {
  name            = "we-bgp-transit-hagw"
  peer_asn        = 65014
  peer_ip         = module.azure_transit_ars.transit_gateway.ha_bgp_lan_ip_list[0]
  route_server_id = module.ars_r1.ars.id
}

## ARS creation in region 1

module "ars_r1" {
  source = "github.com/alexandreweiss/misc-tf-modules.git/ars"

  resource_group_name = azurerm_resource_group.ars-lab-r1.name
  location            = var.azure_r1_location
  subnet_id           = azurerm_subnet.ars-subnet.id
  ars_name            = "ars-${var.azure_r1_location_short}"
  enable_b2b          = true
}

output "ars_r1" {
  value = module.ars_r1.ars
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

resource "azurerm_route_server_bgp_connection" "fw-1" {
  name            = "fw-vm-1"
  peer_asn        = var.asn_fw
  peer_ip         = module.r1-fw-1-vm.vm_private_ip
  route_server_id = module.ars_r1.ars.id
}

resource "azurerm_route_server_bgp_connection" "fw-2" {
  name            = "fw-vm-2"
  peer_asn        = var.asn_fw
  peer_ip         = module.r1-fw-2-vm.vm_private_ip
  route_server_id = module.ars_r1.ars.id
}

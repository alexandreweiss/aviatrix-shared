## ARS creation in region 1

module "ars_spoke_r1" {
  source = "github.com/alexandreweiss/misc-tf-modules.git/ars"

  resource_group_name = azurerm_resource_group.ars-lab-r1.name
  location            = var.azure_r1_location
  subnet_id           = azurerm_subnet.ars-spoke-subnet.id
  ars_name            = "ars-spoke-${var.azure_r1_location_short}"
  enable_b2b          = true
}

output "ars_spoke_r1" {
  value = module.ars_spoke_r1.ars
}

# resource "azurerm_route_server_bgp_connection" "fw-1-ars-spoke" {
#   name            = "fw-vm-1"
#   peer_asn        = var.asn_fw
#   peer_ip         = module.r1-fw-1-vm.vm_private_ip
#   route_server_id = module.ars_spoke_r1.ars.id
#   depends_on      = [azurerm_route_server_bgp_connection.avx-hagw]
# }

# resource "azurerm_route_server_bgp_connection" "fw-2" {
#   name            = "fw-vm-2"
#   peer_asn        = var.asn_fw
#   peer_ip         = module.r1-fw-2-vm.vm_private_ip
#   route_server_id = module.ars_spoke_r1.ars.id
#   depends_on      = [azurerm_route_server_bgp_connection.fw-1]
# }

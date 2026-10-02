resource "azurerm_express_route_circuit" "er-circuit" {
  location            = var.location
  name                = var.circuit_name
  resource_group_name = var.resource_group_name
  sku {
    family = "MeteredData"
    tier   = "Standard"
  }
  bandwidth_in_mbps     = var.circuit_bandwidth
  service_provider_name = "PacketFabric"
  peering_location      = var.peering_location
}

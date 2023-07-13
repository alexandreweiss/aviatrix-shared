output "transit_we" {
  value     = module.azure_transit_we
  sensitive = true
}

output "transit_we_rg" {
  value = azurerm_resource_group.azr-transit-r1-0-rg.name
}

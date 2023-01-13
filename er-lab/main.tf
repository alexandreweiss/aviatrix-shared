resource "azurerm_resource_group" "er-lab" {
  location = "eastus2"
  name     = "er-lab"
}

module "er-circuit-pf" {
  source = "github.com/alexandreweiss/misc-tf-modules/er-circuit"

  circuit_name        = "er-pf-newyork"
  peering_location    = "New York"
  location            = azurerm_resource_group.er-lab.location
  resource_group_name = azurerm_resource_group.er-lab.name
}

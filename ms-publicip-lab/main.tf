provider "azurerm" {
  features {}
}

data "azurerm_network_service_tags" "example" {
  location        = "northeurope"
  service         = "PowerPlatformInfra"
  location_filter = "westeurope"
}

output "address_prefixes" {
  value = data.azurerm_network_service_tags.example.address_prefixes
}

output "ipv4_cidrs" {
  value = data.azurerm_network_service_tags.example.ipv4_cidrs
}
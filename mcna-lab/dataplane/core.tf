resource "azurerm_resource_group" "azr-transit-r1-0-rg" {
  location = var.azure_r1_location
  name     = "azr-transit-${var.azure_r1_location_short}-0-rg"
}

resource "azurerm_resource_group" "azr-transit-r1-1-rg" {
  location = var.azure_r1_location
  name     = "azr-transit-${var.azure_r1_location_short}-1-rg"
}

resource "azurerm_resource_group" "azr-transit-ne-0-rg" {
  location = var.azure_r2_location
  name     = "azr-transit-ne-0-rg"
}

resource "azurerm_resource_group" "azr-r1-spoke-microseg-rg" {
  location = var.azure_r1_location
  name     = "azr-${var.azure_r1_location_short}-spoke-microseg-rg"
}

resource "azurerm_resource_group" "azr-r1-spoke-app-b-microseg-rg" {
  location = var.azure_r1_location
  name     = "azr-${var.azure_r1_location_short}-spoke-app-b-microseg-rg"
}

resource "azurerm_resource_group" "avx-lab-vms-rg" {
  name     = "avx-lab-vms-rg"
  location = var.azure_r2_location
}

# resource "azurerm_private_dns_zone" "avx-local" {
#     name = "avx.lab"
#     resource_group_name = azurerm_resource_group.corerg.name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "avx-local-0" {
#     name = "avx-local-${var.azure_r1_location_short}-spoke-prd"
#     private_dns_zone_name = azurerm_private_dns_zone.avx-local.name
#     resource_group_name = azurerm_private_dns_zone.avx-local.resource_group_name
#     virtual_network_id = data.aviatrix_vpc.we_spoke_prd.azure_vnet_resource_id
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "avx-local-1" {
#     name = "avx-local-${var.azure_r1_location_short}-spoke-dev"
#     private_dns_zone_name = azurerm_private_dns_zone.avx-local.name
#     resource_group_name = azurerm_private_dns_zone.avx-local.resource_group_name
#     virtual_network_id = data.aviatrix_vpc.we_spoke_dev.azure_vnet_resource_id
# }

# resource "azurerm_private_dns_a_record" "app1-front" {
#     name = "app1-front"
#     records = [ module.we-app1-front-vm.vm_private_ip ]
#     resource_group_name = azurerm_resource_group.corerg.name
#     ttl = 1
#     zone_name = azurerm_private_dns_zone.avx-local.name
# }

# resource "azurerm_private_dns_a_record" "app2-front" {
#     name = "app2-front"
#     records = [ module.we-app2-front-vm.vm_private_ip ]
#     resource_group_name = azurerm_resource_group.corerg.name
#     ttl = 1
#     zone_name = azurerm_private_dns_zone.avx-local.name
# }

# resource "azurerm_private_dns_a_record" "we-dev-vm" {
#     name = "we-dev-vm"
#     records = [ module.we-dev-vm.vm_private_ip ]
#     resource_group_name = azurerm_resource_group.corerg.name
#     ttl = 1
#     zone_name = azurerm_private_dns_zone.avx-local.name
# }

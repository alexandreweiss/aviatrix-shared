resource "azurerm_resource_group" "corerg" {
    location = var.azure_we_location
    name = var.core_resource_group_name
}

resource "azurerm_private_dns_zone" "avx-local" {
    name = "avx.lab"
    resource_group_name = azurerm_resource_group.corerg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "avx-local-0" {
    name = "avx-local-we-spoke-prd"
    private_dns_zone_name = azurerm_private_dns_zone.avx-local.name
    resource_group_name = azurerm_private_dns_zone.avx-local.resource_group_name
    virtual_network_id = data.aviatrix_vpc.we_spoke_prd.azure_vnet_resource_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "avx-local-1" {
    name = "avx-local-we-spoke-dev"
    private_dns_zone_name = azurerm_private_dns_zone.avx-local.name
    resource_group_name = azurerm_private_dns_zone.avx-local.resource_group_name
    virtual_network_id = data.aviatrix_vpc.we_spoke_dev.azure_vnet_resource_id
}

resource "azurerm_private_dns_a_record" "app1-front" {
    name = "app1-front"
    records = [ module.we-app1-front-vm.vm_private_ip ]
    resource_group_name = azurerm_resource_group.corerg.name
    ttl = 1
    zone_name = azurerm_private_dns_zone.avx-local.name
}

resource "azurerm_private_dns_a_record" "app2-front" {
    name = "app2-front"
    records = [ module.we-app2-front-vm.vm_private_ip ]
    resource_group_name = azurerm_resource_group.corerg.name
    ttl = 1
    zone_name = azurerm_private_dns_zone.avx-local.name
}

resource "azurerm_private_dns_a_record" "we-dev-vm" {
    name = "we-dev-vm"
    records = [ module.we-dev-vm.vm_private_ip ]
    resource_group_name = azurerm_resource_group.corerg.name
    ttl = 1
    zone_name = azurerm_private_dns_zone.avx-local.name
}
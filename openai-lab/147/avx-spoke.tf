data "dns_a_record_set" "controller_ip" {
  host = var.controller_fqdn
}

module "azr_r1_spoke_oai" {
  source = "terraform-aviatrix-modules/mc-spoke/aviatrix"

  cloud            = "Azure"
  name             = "azure-oai"
  vpc_id           = "${azurerm_virtual_network.azure-spoke-oai-r1.name}:${azurerm_resource_group.r1-rg.name}:${azurerm_virtual_network.azure-spoke-oai-r1.guid}"
  gw_subnet        = azurerm_subnet.r1-azure-spoke-oai-gw-subnet.address_prefixes[0]
  use_existing_vpc = true
  region           = var.azure_r1_location
  # network_domain   = "azure-oai"
  account        = var.azure_account
  transit_gw     = "azr-we-transit-avx"
  attached       = true
  single_ip_snat = false
  single_az_ha   = false
  ha_gw          = false
  resource_group = azurerm_resource_group.r1-rg.name
}

# resource "aviatrix_segmentation_network_domain_association" "azure-oai-domain-association" {
#   network_domain_name = aviatrix_segmentation_network_domain.azure-oai-domain.domain_name
#   attachment_name     = module.azr_r1_spoke_oai.spoke_gateway.gw_name
# }

# resource "aviatrix_segmentation_network_domain_connection_policy" "azure-oai-aws-prod" {
#   domain_name_1 = aviatrix_segmentation_network_domain.azure-oai-domain.domain_name
#   domain_name_2 = "AWS-Prod"
# }

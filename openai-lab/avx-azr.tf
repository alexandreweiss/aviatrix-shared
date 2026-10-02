data "dns_a_record_set" "controller_ip" {
  host = var.controller_fqdn
}

module "azure_transit_oai" {
  source = "terraform-aviatrix-modules/mc-transit/aviatrix"

  cloud           = "azure"
  region          = var.azure_r1_location
  cidr            = "10.60.0.0/23"
  account         = var.azure_account
  name            = "azr-oai-transit"
  local_as_number = 65012
  single_az_ha    = false
  ha_gw           = false
  instance_size   = "Standard_B2s"
  tags = {
    csp-environment : "tst",
    csp-department : "dept-530",
    shutdown : "stop",
    schedule : "08:00-11:00;mo,tu,we,th,fr;europe-paris"
  }
}

module "azr_r1_spoke_oai" {
  source = "terraform-aviatrix-modules/mc-spoke/aviatrix"

  cloud            = "Azure"
  name             = "azure-oai-spoke"
  vpc_id           = "${azurerm_virtual_network.azure-spoke-oai-r1.name}:${azurerm_resource_group.r1-rg.name}:${azurerm_virtual_network.azure-spoke-oai-r1.guid}"
  gw_subnet        = azurerm_subnet.r1-azure-spoke-oai-gw-subnet.address_prefixes[0]
  use_existing_vpc = true
  region           = var.azure_r1_location
  account          = var.azure_account
  transit_gw       = module.azure_transit_oai.transit_gateway.gw_name
  instance_size    = "Standard_B1ms"
  attached         = true
  single_az_ha     = false
  ha_gw            = false
  resource_group   = azurerm_resource_group.r1-rg.name
}

resource "aviatrix_gateway" "azr_r1_spoke_vpn_oai" {

  cloud_type       = 8
  account_name     = var.azure_account
  gw_name          = "azure-oai-vpn"
  vpc_id           = "${azurerm_virtual_network.azure-spoke-oai-r1.name}:${azurerm_resource_group.r1-rg.name}:${azurerm_virtual_network.azure-spoke-oai-r1.guid}"
  subnet           = azurerm_subnet.r1-azure-spoke-oai-gw-subnet.address_prefixes[0]
  vpc_reg          = var.azure_r1_location
  gw_size          = "Standard_B1ms"
  zone             = "az-1"
  vpn_access       = true
  vpn_cidr         = "172.20.21.0/24"
  additional_cidrs = "10.0.0.0/8"
  max_vpn_conn     = "100"
  split_tunnel     = true
  enable_vpn_nat   = true


  depends_on = [
    azurerm_subnet.r1-azure-spoke-oai-gw-subnet
  ]
}

# resource "aviatrix_segmentation_network_domain" "azure-oai-domain" {
#   domain_name = "Azure-oai"
# }

# resource "aviatrix_segmentation_network_domain_association" "azure-oai-domain-association" {
#   network_domain_name = aviatrix_segmentation_network_domain.azure-oai-domain.domain_name
#   attachment_name     = module.azr_r1_spoke_oai.spoke_gateway.gw_name
# }

resource "aviatrix_segmentation_network_domain_connection_policy" "azure-oai-aws-prod" {
  domain_name_1 = aviatrix_segmentation_network_domain.azure-oai-domain.domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.aws-prod-domain.domain_name
  depends_on    = [aviatrix_segmentation_network_domain.aws-prod-domain, aviatrix_segmentation_network_domain.azure-oai-domain]
}

resource "aviatrix_segmentation_network_domain" "azure-oai-domain" {
  domain_name = "azure-oai"
}

resource "aviatrix_segmentation_network_domain" "aws-prod-domain" {
  domain_name = "aws-prod"
}

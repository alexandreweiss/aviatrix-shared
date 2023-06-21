// PRD SPOKE in R1

resource "azurerm_virtual_network" "azure-spoke-prd-r1" {
  address_space       = ["10.10.1.0/24"]
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-prd-vn"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-prd-rg.name
}

resource "azurerm_subnet" "r1-azure-spoke-prd-gw-subnet" {
  address_prefixes     = ["10.10.1.0/28"]
  name                 = "avx-gw-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-prd-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-prd-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-prd-hagw-subnet" {
  address_prefixes     = ["10.10.1.16/28"]
  name                 = "avx-hagw-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-prd-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-prd-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-prd-vm-subnet" {
  address_prefixes     = ["10.10.1.32/28"]
  name                 = "avx-vm-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-prd-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-prd-r1.name
}

resource "azurerm_route_table" "r1-azure-spoke-prd-vm-subnet-rt" {
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-prd-vm-subnet-rt"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-prd-rg.name

  route {
    address_prefix = "0.0.0.0/0"
    name           = "internetDefaultBlackhole"
    next_hop_type  = "None"
  }

  lifecycle {
    ignore_changes = [
      route,
    ]
  }
}

resource "azurerm_subnet_route_table_association" "prd-subnet-vm-rt-assoc" {
  route_table_id = azurerm_route_table.r1-azure-spoke-prd-vm-subnet-rt.id
  subnet_id      = azurerm_subnet.r1-azure-spoke-prd-vm-subnet.id
}

module "we_spoke_prd" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.6.1"
  count   = local.features.deploy_azr_we_spoke_prd ? 1 : 0

  cloud            = "Azure"
  name             = "we-spoke-prd"
  vpc_id           = "${azurerm_virtual_network.azure-spoke-prd-r1.name}:${azurerm_resource_group.azr-r1-spoke-prd-rg.name}:${azurerm_virtual_network.azure-spoke-prd-r1.guid}"
  gw_subnet        = azurerm_subnet.r1-azure-spoke-prd-gw-subnet.address_prefixes[0]
  hagw_subnet      = azurerm_subnet.r1-azure-spoke-prd-hagw-subnet.address_prefixes[0]
  use_existing_vpc = true
  region           = var.azure_r1_location
  account          = local.accounts.azure_account
  transit_gw       = module.azure_transit_we.transit_gateway.gw_name
  //transit_gw_egress = module.azure_transit_we_egress.transit_gateway.gw_name
  //network_domain = aviatrix_segmentation_network_domain.prd_nd.domain_name
  ha_gw          = true
  single_az_ha   = false
  resource_group = azurerm_resource_group.azr-r1-spoke-prd-rg.name
  single_ip_snat = true
}


// DEV SPOKE in R1
resource "azurerm_virtual_network" "azure-spoke-dev-r1" {
  address_space       = ["10.10.2.0/24"]
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-dev-vn"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-dev-rg.name
}

resource "azurerm_subnet" "r1-azure-spoke-dev-gw-subnet" {
  address_prefixes     = ["10.10.2.0/28"]
  name                 = "avx-gw-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-dev-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-dev-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-dev-hagw-subnet" {
  address_prefixes     = ["10.10.2.16/28"]
  name                 = "avx-hagw-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-dev-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-dev-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-dev-vm-subnet" {
  address_prefixes     = ["10.10.2.32/28"]
  name                 = "avx-vm-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-dev-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-dev-r1.name
}

resource "azurerm_route_table" "r1-azure-spoke-dev-vm-subnet-rt" {
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-dev-vm-subnet-rt"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-dev-rg.name

  route {
    address_prefix = "0.0.0.0/0"
    name           = "internetDefaultBlackhole"
    next_hop_type  = "None"
  }

  lifecycle {
    ignore_changes = [
      route,
    ]
  }
}

resource "azurerm_subnet_route_table_association" "dev-subnet-vm-rt-assoc" {
  route_table_id = azurerm_route_table.r1-azure-spoke-dev-vm-subnet-rt.id
  subnet_id      = azurerm_subnet.r1-azure-spoke-dev-vm-subnet.id
}

module "we_spoke_dev" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.6.1"
  count   = local.features.deploy_azr_we_spoke_dev ? 1 : 0

  cloud            = "Azure"
  name             = "we-spoke-dev"
  vpc_id           = "${azurerm_virtual_network.azure-spoke-dev-r1.name}:${azurerm_resource_group.azr-r1-spoke-dev-rg.name}:${azurerm_virtual_network.azure-spoke-dev-r1.guid}"
  gw_subnet        = azurerm_subnet.r1-azure-spoke-dev-gw-subnet.address_prefixes[0]
  use_existing_vpc = true
  hagw_subnet      = azurerm_subnet.r1-azure-spoke-dev-hagw-subnet.address_prefixes[0]
  region           = var.azure_r1_location
  account          = local.accounts.azure_account
  transit_gw       = module.azure_transit_we.transit_gateway.gw_name
  ha_gw            = false
  //network_domain = aviatrix_segmentation_network_domain.dev_nd.domain_name
  single_ip_snat = true
  single_az_ha   = false
  resource_group = azurerm_resource_group.azr-r1-spoke-dev-rg.name
}

// SPOKE VPN

resource "azurerm_virtual_network" "azure-spoke-vpn-r1" {
  address_space       = ["10.10.3.0/24"]
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-vpn-vn"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-vpn-rg.name
}

resource "azurerm_subnet" "r1-azure-spoke-vpn-gw-subnet" {
  address_prefixes     = ["10.10.3.0/28"]
  name                 = "avx-gw-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-vpn-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-vpn-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-vpn-hagw-subnet" {
  address_prefixes     = ["10.10.3.16/28"]
  name                 = "avx-hagw-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-vpn-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-vpn-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-vpn-vm-subnet" {
  address_prefixes     = ["10.10.3.32/28"]
  name                 = "avx-vm-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-vpn-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-vpn-r1.name
}

module "we_spoke_vpn" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.6.1"
  count   = local.features.deploy_azr_vpn_spoke ? 1 : 0

  cloud     = "Azure"
  name      = "we-spoke-vpn"
  vpc_id    = "${azurerm_virtual_network.azure-spoke-vpn-r1.name}:${azurerm_resource_group.azr-r1-spoke-vpn-rg.name}:${azurerm_virtual_network.azure-spoke-vpn-r1.guid}"
  gw_subnet = azurerm_subnet.r1-azure-spoke-vpn-gw-subnet.address_prefixes[0]
  //hagw_subnet    = azurerm_subnet.r1-azure-spoke-vpn-hagw-subnet.address_prefixes[0]
  use_existing_vpc = true
  region           = var.azure_r1_location
  account          = local.accounts.azure_account
  transit_gw       = module.azure_transit_we.transit_gateway.gw_name
  ha_gw            = false
  single_az_ha     = false
  //network_domain   = aviatrix_segmentation_network_domain.vpn_nd.domain_name
  resource_group = azurerm_resource_group.azr-r1-spoke-vpn-rg.name
}

resource "aviatrix_gateway" "we-vpn-0" {
  count = local.features.deploy_azr_vpn_gw && local.features.deploy_azr_vpn_spoke ? 1 : 0

  cloud_type       = 8
  account_name     = local.accounts.azure_account
  gw_name          = "${var.azure_r1_location_short}-vpn-0"
  vpc_id           = "${azurerm_virtual_network.azure-spoke-vpn-r1.name}:${azurerm_resource_group.azr-r1-spoke-vpn-rg.name}:${azurerm_virtual_network.azure-spoke-vpn-r1.guid}"
  vpc_reg          = var.azure_r1_location
  gw_size          = "Standard_B1ms"
  subnet           = "10.10.3.16/28"
  zone             = "az-1"
  vpn_access       = true
  vpn_cidr         = "172.20.20.0/24"
  additional_cidrs = var.p2s_additional_cidrs
  max_vpn_conn     = "100"
  split_tunnel     = true


  depends_on = [
    module.we_spoke_vpn
  ]
}

// Peering to controller for internal management

# data "aviatrix_vpc" "we_spoke_vpn" {
#   name = module.we_spoke_vpn[0].vpc.name
#   depends_on = [
#     module.we_spoke_vpn
#   ]
# }

module "controller-vpn-spoke-peering" {
  source = "github.com/alexandreweiss/terraform-azurerm-vnetpeering"
  count  = local.features.deploy_azr_vpn_spoke ? 1 : 0

  left_vnet_resource_group_name  = azurerm_resource_group.azr-r1-spoke-vpn-rg.name
  left_vnet_name                 = azurerm_virtual_network.azure-spoke-vpn-r1.name
  right_vnet_resource_group_name = local.controller.controller_resource_group_name
  right_vnet_name                = local.controller.controller_vnet_name

  depends_on = [
    azurerm_virtual_network.azure-spoke-vpn-r1
  ]
}

# module "ne_spoke_prd" {
#   source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
#   version = "1.6.1"
#   count   = local.features.deploy_azr_ne_spoke ? 1 : 0

#   cloud      = "Azure"
#   name       = "ne-spoke-prd"
#   cidr       = "10.20.1.0/24"
#   region     = var.azure_r2_location
#   account    = local.accounts.azure_account
#   transit_gw = module.azure_transit_ne.transit_gateway.gw_name
#   //network_domain  = aviatrix_segmentation_network_domain.prd_nd.domain_name
# }

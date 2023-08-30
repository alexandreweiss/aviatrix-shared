// DEV SPOKE in R1

resource "azurerm_resource_group" "azr-r1-spoke-dev-rg" {
  location = var.azure_r1_location
  name     = "azr-${var.azure_r1_location_short}-spoke-dev-rg"
}

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

module "azr_r1_spoke_dev" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.6.1"

  cloud            = "Azure"
  name             = "${var.azure_r1_location_short}-spoke-dev"
  vpc_id           = "${azurerm_virtual_network.azure-spoke-dev-r1.name}:${azurerm_resource_group.azr-r1-spoke-dev-rg.name}:${azurerm_virtual_network.azure-spoke-dev-r1.guid}"
  gw_subnet        = azurerm_subnet.r1-azure-spoke-dev-gw-subnet.address_prefixes[0]
  use_existing_vpc = true
  hagw_subnet      = azurerm_subnet.r1-azure-spoke-dev-hagw-subnet.address_prefixes[0]
  region           = var.azure_r1_location
  account          = var.azure_account
  transit_gw       = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name
  ha_gw            = false
  //network_domain = aviatrix_segmentation_network_domain.dev_nd.domain_name
  single_ip_snat  = true
  single_az_ha    = false
  resource_group  = azurerm_resource_group.azr-r1-spoke-dev-rg.name
  local_as_number = 65012
  enable_bgp      = true
}

module "we-dev-vm" {
  source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  environment         = "dev"
  location            = var.azure_r1_location
  location_short      = var.azure_r1_location_short
  index_number        = 01
  resource_group_name = azurerm_resource_group.azr-r1-spoke-dev-rg.name
  subnet_id           = azurerm_subnet.r1-azure-spoke-dev-vm-subnet.id
  admin_ssh_key       = var.ssh_public_key
  depends_on = [
  ]
}

output "spoke_dev" {
  value     = module.azr_r1_spoke_dev
  sensitive = true
}

resource "azurerm_resource_group" "we-spoke-w365-rg" {
    location = var.azure_we_location
    name = "we-spoke-w365-rg"
}

resource "azurerm_virtual_network" "we-spoke-w365" {
  address_space = [ "10.10.4.0/24" ]
  location = var.azure_we_location
  name = "we-spoke-w365"
  resource_group_name = azurerm_resource_group.we-spoke-w365-rg.name
}

resource "azurerm_subnet" "avx-gw-subnet" {
    address_prefixes = [ "10.10.4.0/28" ]
    name = "avx-gw-subnet"
    resource_group_name = azurerm_resource_group.we-spoke-w365-rg.name
    virtual_network_name = azurerm_virtual_network.we-spoke-w365.name
}

resource "azurerm_subnet" "vm-subnet" {
    address_prefixes = [ "10.10.4.16/28" ]
    name = "vm-subnet"
    resource_group_name = azurerm_resource_group.we-spoke-w365-rg.name
    virtual_network_name = azurerm_virtual_network.we-spoke-w365.name
}

resource "azurerm_route_table" "we-spoke-w365-rt" {
  location = var.azure_we_location
  name = "we-spoke-w365-rt"
  resource_group_name = azurerm_resource_group.we-spoke-w365-rg.name
}

resource "azurerm_route" "optimize-m365-route" {
  address_prefix = "WindowsVirtualDesktop"
  name = "OptimizeM365Routes"
  next_hop_type = "Internet"
  resource_group_name = azurerm_resource_group.we-spoke-w365-rg.name
  route_table_name = azurerm_route_table.we-spoke-w365-rt.name
  depends_on = [
    module.we_spoke_w365
  ]
}

resource "azurerm_subnet_route_table_association" "optimize-m365-assoc" {
    route_table_id = azurerm_route_table.we-spoke-w365-rt.id
    subnet_id = azurerm_subnet.vm-subnet.id
}

module "we_spoke_w365" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.5.0"
  count = local.features.deploy_azr_we_spoke_w365 ? 1 : 0

  cloud             = "Azure"
  name              = "we-spoke-w365"
  use_existing_vpc  = true
  vpc_id            = "${azurerm_virtual_network.we-spoke-w365.name}:${azurerm_resource_group.we-spoke-w365-rg.name}:${azurerm_virtual_network.we-spoke-w365.guid}"
  gw_subnet         = azurerm_subnet.avx-gw-subnet.address_prefixes[0]
  region            = var.azure_we_location
  account           = local.accounts.azure_account
  transit_gw        = module.azure_transit_we.transit_gateway.gw_name
  network_domain    = aviatrix_segmentation_network_domain.w365_nd.domain_name
  resource_group    = azurerm_resource_group.we-spoke-w365-rg.name
  ha_gw             = false
}

module "we-w365-vm" {
  source = "github.com/alexandreweiss/misc-tf-modules/azr-win-vm"
  environment = "w365"
  location = var.azure_we_location
  location_short = var.azure_we_location_short
  index_number = 01
  resource_group_name = azurerm_resource_group.we-spoke-w365-rg.name
  subnet_id = azurerm_subnet.vm-subnet.id
  admin_password = var.admin_password
}
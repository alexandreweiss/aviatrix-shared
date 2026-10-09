// APP2 SPOKE in R1 - IPv4 workload, attached to transit-1

resource "azurerm_resource_group" "azr-r1-spoke-app2-rg" {
  location = var.azure_r1_location
  name     = "azr-${var.azure_r1_location_short}-spoke-${var.application_2}-${var.customer_name}-rg"
}

resource "azurerm_virtual_network" "azure-spoke-app2-r1" {
  address_space       = ["10.10.2.0/23"]
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-${var.application_2}-vn"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-app2-rg.name
}

resource "azurerm_subnet" "r1-azure-spoke-app2-gw-subnet" {
  address_prefixes     = ["10.10.2.0/26"]
  name                 = "avx-gw-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-app2-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-app2-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-app2-hagw-subnet" {
  address_prefixes     = ["10.10.2.64/26"]
  name                 = "avx-hagw-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-app2-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-app2-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-app2-vm-subnet" {
  address_prefixes     = ["10.10.2.128/28"]
  name                 = "avx-vm-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-app2-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-app2-r1.name
}

resource "azurerm_route_table" "r1-azure-spoke-app2-vm-subnet-rt" {
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-${var.application_2}-vm-subnet-rt"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-app2-rg.name

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

resource "azurerm_subnet_route_table_association" "app2-subnet-vm-rt-assoc" {
  route_table_id = azurerm_route_table.r1-azure-spoke-app2-vm-subnet-rt.id
  subnet_id      = azurerm_subnet.r1-azure-spoke-app2-vm-subnet.id
}

module "azr_r1_spoke_app2" {
  source = "terraform-aviatrix-modules/mc-spoke/aviatrix"

  cloud            = "Azure"
  name             = "azr-${var.azure_r1_location_short}-spoke-${var.application_2}-${var.customer_name}"
  vpc_id           = "${azurerm_virtual_network.azure-spoke-app2-r1.name}:${azurerm_resource_group.azr-r1-spoke-app2-rg.name}:${azurerm_virtual_network.azure-spoke-app2-r1.guid}"
  use_existing_vpc = true
  gw_subnet        = azurerm_subnet.r1-azure-spoke-app2-gw-subnet.address_prefixes[0]
  enable_ipv6      = false
  region           = var.azure_r1_location
  account          = var.azure_account
  transit_gw       = data.tfe_outputs.dataplane.values.transit_we_1.transit_gateway.gw_name
  attached         = true
  ha_gw            = false
  single_ip_snat   = true
  single_az_ha     = false
  resource_group   = azurerm_resource_group.azr-r1-spoke-app2-rg.name
  enable_bgp       = false
  instance_size    = "Standard_B2ms"
  insane_mode      = false
  depends_on       = [azurerm_subnet_route_table_association.app2-subnet-vm-rt-assoc]
}

module "we-app2-vm" {
  source      = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  environment = var.application_2
  tags = {
    "application" = var.application_2
  }
  location            = var.azure_r1_location
  location_short      = var.azure_r1_location_short
  index_number        = 01
  resource_group_name = azurerm_resource_group.azr-r1-spoke-app2-rg.name
  subnet_id           = azurerm_subnet.r1-azure-spoke-app2-vm-subnet.id
  admin_ssh_key       = var.ssh_public_key
  customer_name       = var.customer_name
  depends_on          = []
}

output "spoke_app2" {
  value     = module.azr_r1_spoke_app2
  sensitive = true
}

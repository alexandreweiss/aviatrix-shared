// APP3 SPOKE in R1 - IPv6 only workload

resource "azurerm_resource_group" "azr-r1-spoke-app3-rg" {
  location = var.azure_r1_location
  name     = "azr-${var.azure_r1_location_short}-spoke-${var.application_3}-${var.customer_name}-rg"
}

resource "azurerm_virtual_network" "azure-spoke-app3-r1" {
  address_space       = ["10.10.8.0/23", "fd00:10:12::/48"]
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-${var.application_3}-vn"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-app3-rg.name
}

resource "azurerm_subnet" "r1-azure-spoke-app3-gw-subnet" {
  address_prefixes     = ["10.10.8.0/26", "fd00:10:12:2::/64"]
  name                 = "avx-gw-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-app3-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-app3-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-app3-hagw-subnet" {
  address_prefixes     = ["10.10.8.64/26", "fd00:10:12:3::/64"]
  name                 = "avx-hagw-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-app3-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-app3-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-app3-vm-subnet" {
  address_prefixes     = ["10.10.8.128/28", "fd00:10:12:1::/64"]
  name                 = "avx-vm-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-app3-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-app3-r1.name
}

resource "azurerm_route_table" "r1-azure-spoke-app3-vm-subnet-rt" {
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-${var.application_3}-vm-subnet-rt"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-app3-rg.name

  route {
    address_prefix = "0.0.0.0/0"
    name           = "internetDefaultBlackhole"
    next_hop_type  = "None"
  }

  route {
    address_prefix = "::/0"
    name           = "internetDefaultBlackholeIPv6"
    next_hop_type  = "None"
  }

  lifecycle {
    ignore_changes = [
      route,
    ]
  }
}

resource "azurerm_subnet_route_table_association" "app3-subnet-vm-rt-assoc" {
  route_table_id = azurerm_route_table.r1-azure-spoke-app3-vm-subnet-rt.id
  subnet_id      = azurerm_subnet.r1-azure-spoke-app3-vm-subnet.id
}

module "azr_r1_spoke_app3" {
  source = "terraform-aviatrix-modules/mc-spoke/aviatrix"

  cloud            = "Azure"
  name             = "azr-${var.azure_r1_location_short}-spoke-${var.application_3}-${var.customer_name}"
  vpc_id           = "${azurerm_virtual_network.azure-spoke-app3-r1.name}:${azurerm_resource_group.azr-r1-spoke-app3-rg.name}:${azurerm_virtual_network.azure-spoke-app3-r1.guid}"
  use_existing_vpc = true
  gw_subnet        = azurerm_subnet.r1-azure-spoke-app3-gw-subnet.address_prefixes[0]
  enable_ipv6      = true
  ipv6_gw_subnet   = azurerm_subnet.r1-azure-spoke-app3-gw-subnet.address_prefixes[1]
  region           = var.azure_r1_location
  account          = var.azure_account
  transit_gw       = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name
  attached         = true
  ha_gw            = false
  single_ip_snat   = true
  single_az_ha     = false
  resource_group   = azurerm_resource_group.azr-r1-spoke-app3-rg.name
  enable_bgp       = false
  instance_size    = "Standard_B2ms"
  insane_mode      = false
  depends_on       = [azurerm_subnet_route_table_association.app3-subnet-vm-rt-assoc]
}

module "azr-app3-ipv6-vm" {
  source      = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  environment = var.application_3
  tags = {
    "application" = var.application_3
    "environment" = "ipv6-workload"
  }
  location            = var.azure_r1_location
  location_short      = var.azure_r1_location_short
  index_number        = 01
  resource_group_name = azurerm_resource_group.azr-r1-spoke-app3-rg.name
  subnet_id           = azurerm_subnet.r1-azure-spoke-app3-vm-subnet.id
  ipv6_subnet_id      = azurerm_subnet.r1-azure-spoke-app3-vm-subnet.id
  admin_ssh_key       = var.ssh_public_key
  customer_name       = var.customer_name
  enable_ipv6         = true
  depends_on          = []
}

output "spoke_app3" {
  value     = module.azr_r1_spoke_app3
  sensitive = true
}

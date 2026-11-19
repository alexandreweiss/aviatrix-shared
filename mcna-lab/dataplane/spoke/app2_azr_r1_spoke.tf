// APP2 SPOKE in R1
// Standalone spoke: NOT attached to transit, BGP enabled, ready for an
// external BGP over IPsec connection (aviatrix_spoke_external_device_conn).

resource "azurerm_resource_group" "azr-r1-spoke-app2-rg" {
  location = var.azure_r1_location
  name     = "azr-${var.azure_r1_location_short}-spoke-${var.application_2}-${var.customer_name}-rg"
}

resource "azurerm_virtual_network" "azure-spoke-app2-r1" {
  address_space       = ["10.10.6.0/23"]
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-${var.application_2}-vn"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-app2-rg.name
}

resource "azurerm_subnet" "r1-azure-spoke-app2-gw-subnet" {
  address_prefixes     = ["10.10.6.0/26"]
  name                 = "avx-gw-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-app2-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-app2-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-app2-hagw-subnet" {
  address_prefixes     = ["10.10.6.64/26"]
  name                 = "avx-hagw-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-app2-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-app2-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-app2-vm-subnet" {
  address_prefixes     = ["10.10.6.128/28"]
  name                 = "avx-vm-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-app2-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-app2-r1.name
}

resource "azurerm_route_table" "r1-azure-spoke-app2-vm-subnet-rt" {
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-${var.application_2}-vm-subnet-rt"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-app2-rg.name

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
  gw_subnet        = azurerm_subnet.r1-azure-spoke-app2-gw-subnet.address_prefixes[0]
  hagw_subnet      = azurerm_subnet.r1-azure-spoke-app2-hagw-subnet.address_prefixes[0]
  use_existing_vpc = true
  region           = var.azure_r1_location
  account          = var.azure_account
  resource_group   = azurerm_resource_group.azr-r1-spoke-app2-rg.name

  # Not attached to any transit
  attached = false

  # BGP enabled, ready for BGP over IPsec to an external device
  enable_bgp      = true
  local_as_number = 65012

  ha_gw          = true
  single_ip_snat = true
  single_az_ha   = false

  # Egress: Aviatrix programs the default route on this private route table
  private_route_table_config = [
    "${azurerm_route_table.r1-azure-spoke-app2-vm-subnet-rt.name}:${azurerm_resource_group.azr-r1-spoke-app2-rg.name}",
  ]
  instance_size = "Standard_B2ms"
  insane_mode   = false

  depends_on = [azurerm_subnet_route_table_association.app2-subnet-vm-rt-assoc]
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
}

output "spoke_app2" {
  value     = module.azr_r1_spoke_app2
  sensitive = true
}

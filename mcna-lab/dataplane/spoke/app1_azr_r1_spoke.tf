// APP1 SPOKE in R1

// Replace app1 by app2 as need be
// Replace application_1 by application_2 as need be
// Replace CIDR block as need be 10.10.2 for app1, 10.11.2 for app2 ...

resource "azurerm_resource_group" "azr-r1-spoke-app1-rg" {
  location = var.azure_r1_location
  name     = "azr-${var.azure_r1_location_short}-spoke-${var.application_1}-${var.customer_name}-rg"
}

resource "azurerm_virtual_network" "azure-spoke-app1-r1" {
  address_space       = ["10.10.4.0/23"]
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-${var.application_1}-vn"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-app1-rg.name
}

# Comment out for HPE
resource "azurerm_subnet" "r1-azure-spoke-app1-gw-subnet" {
  address_prefixes     = ["10.10.4.0/26"]
  name                 = "avx-gw-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-app1-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-app1-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-app1-hagw-subnet" {
  address_prefixes     = ["10.10.4.64/26"]
  name                 = "avx-hagw-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-app1-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-app1-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-app1-vm-subnet" {
  address_prefixes     = ["10.10.4.128/28"]
  name                 = "avx-vm-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-app1-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-app1-r1.name
}

resource "azurerm_route_table" "r1-azure-spoke-app1-vm-subnet-rt" {
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-${var.application_1}-vm-subnet-rt"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-app1-rg.name

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

resource "azurerm_subnet" "r1-azure-spoke-app1-vm-subnet-2" {
  address_prefixes     = ["10.10.4.144/28"]
  name                 = "avx-vm-subnet-2"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-app1-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-app1-r1.name
}


resource "azurerm_subnet" "r1-azure-spoke-app1-aci-subnet" {
  address_prefixes     = ["10.10.4.160/28"]
  name                 = "aci-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-app1-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-app1-r1.name
  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_route_table" "r1-azure-spoke-app1-vm-subnet-2-rt" {
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-${var.application_1}-vm-subnet-2-rt"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-app1-rg.name

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

resource "azurerm_route_table" "r1-azure-spoke-app1-aci-subnet-rt" {
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-${var.application_1}-aci-subnet-rt"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-app1-rg.name

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

resource "azurerm_subnet_route_table_association" "app1-subnet-vm-rt-assoc" {
  route_table_id = azurerm_route_table.r1-azure-spoke-app1-vm-subnet-rt.id
  subnet_id      = azurerm_subnet.r1-azure-spoke-app1-vm-subnet.id
}

resource "azurerm_subnet_route_table_association" "app1-subnet-vm-2-rt-assoc" {
  route_table_id = azurerm_route_table.r1-azure-spoke-app1-vm-subnet-2-rt.id
  subnet_id      = azurerm_subnet.r1-azure-spoke-app1-vm-subnet-2.id
}

resource "azurerm_subnet_route_table_association" "app1-subnet-aci-rt-assoc" {
  route_table_id = azurerm_route_table.r1-azure-spoke-app1-aci-subnet-rt.id
  subnet_id      = azurerm_subnet.r1-azure-spoke-app1-aci-subnet.id
}

module "azr_r1_spoke_app1" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.6.3"

  cloud     = "Azure"
  name      = "azr-${var.azure_r1_location_short}-spoke-${var.application_1}-${var.customer_name}"
  vpc_id    = "${azurerm_virtual_network.azure-spoke-app1-r1.name}:${azurerm_resource_group.azr-r1-spoke-app1-rg.name}:${azurerm_virtual_network.azure-spoke-app1-r1.guid}"
  gw_subnet = azurerm_subnet.r1-azure-spoke-app1-gw-subnet.address_prefixes[0]
  #  For HPE
  #gw_subnet = "10.10.2.0/26"
  ###
  use_existing_vpc = true
  hagw_subnet      = azurerm_subnet.r1-azure-spoke-app1-hagw-subnet.address_prefixes[0]
  # For HPE
  #hagw_subnet = "10.10.3.0/26"
  ###
  region     = var.azure_r1_location
  account    = var.azure_account
  transit_gw = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name
  attached   = false
  # Must be enabled for HPE
  ha_gw = false
  //network_domain = aviatrix_segmentation_network_domain.dev_nd.domain_name
  single_ip_snat = true
  single_az_ha   = false
  resource_group = azurerm_resource_group.azr-r1-spoke-app1-rg.name
  #local_as_number = 65012
  enable_bgp = false
  depends_on = [azurerm_subnet_route_table_association.app1-subnet-aci-rt-assoc, azurerm_subnet_route_table_association.app1-subnet-vm-2-rt-assoc, azurerm_subnet_route_table_association.app1-subnet-vm-rt-assoc]
  //instance_size            = "Standard_D4s_v3"
  insane_mode = false
  #bgp_lan_interfaces_count = 1
  #enable_bgp_over_lan      = true
}

module "we-app1-vm" {
  source      = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  environment = var.application_1
  tags = {
    "application" = var.application_1
  }
  location            = var.azure_r1_location
  location_short      = var.azure_r1_location_short
  index_number        = 01
  resource_group_name = azurerm_resource_group.azr-r1-spoke-app1-rg.name
  subnet_id           = azurerm_subnet.r1-azure-spoke-app1-vm-subnet.id
  admin_ssh_key       = var.ssh_public_key
  customer_name       = var.customer_name
  //vm_size             = "Standard_DS4_v2"
  depends_on = [
  ]
}

# module "we-app1-vm-2" {
#   source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
#   environment         = var.application_1
#   location            = var.azure_r1_location
#   location_short      = var.azure_r1_location_short
#   index_number        = 02
#   resource_group_name = azurerm_resource_group.azr-r1-spoke-app1-rg.name
#   subnet_id           = azurerm_subnet.r1-azure-spoke-app1-vm-subnet-2.id
#   admin_ssh_key       = var.ssh_public_key
#   depends_on = [
#   ]
# }

output "spoke_app1" {
  value     = module.azr_r1_spoke_app1
  sensitive = true
}

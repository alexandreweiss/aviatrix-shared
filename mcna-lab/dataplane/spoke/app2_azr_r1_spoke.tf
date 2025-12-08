// APP2 SPOKE in R1

// Replace app1 by app2 as need be
// Replace application_1 by application_2 as need be
// Replace CIDR block as need be 10.10.2 for app1, 10.10.2 for app2 ...

resource "azurerm_resource_group" "azr-r1-spoke-app2-rg" {
  location = var.azure_r1_location
  name     = "azr-${var.azure_r1_location_short}-spoke-${var.application_2}-${var.customer_name}-rg"
}

resource "azurerm_virtual_network" "azure-spoke-app2-r1" {
  # address_space       = ["10.10.2.0/24", "192.168.166.0/24"]
  # address_space = ["10.10.2.0/24"]
  address_space = ["10.10.2.0/23"]
  #address_space       = ["192.168.16.0/24"]
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-${var.application_2}-vn"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-app2-rg.name
}

# Comment out GW subnets if HPE is enabled
resource "azurerm_subnet" "r1-azure-spoke-app2-gw-subnet" {
  # address_prefixes = ["192.168.16.0/26"]
  address_prefixes = ["10.10.2.0/26"]
  # address_prefixes     = ["192.168.166.0/26"]
  name                 = "avx-gw-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-app2-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-app2-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-app2-hagw-subnet" {
  # address_prefixes = ["192.168.16.64/26"]
  address_prefixes = ["10.10.2.64/26"]
  # address_prefixes     = ["192.168.166.64/26"]
  name                 = "avx-hagw-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-app2-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-app2-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-app2-vm-subnet" {
  #address_prefixes     = ["192.168.16.128/28"]
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

resource "azurerm_subnet" "r1-azure-spoke-app2-vm-subnet-2" {
  #address_prefixes     = ["192.168.16.144/28"]
  address_prefixes     = ["10.10.2.144/28"]
  name                 = "avx-vm-subnet-2"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-app2-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-app2-r1.name
}

resource "azurerm_route_table" "r1-azure-spoke-app2-vm-subnet-2-rt" {
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-${var.application_2}-vm-subnet-2-rt"
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

resource "azurerm_subnet" "r1-azure-spoke-app2-aci-subnet" {
  # address_prefixes     = ["192.168.16.160/28"]
  address_prefixes     = ["10.10.2.160/28"]
  name                 = "aci-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-app2-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-app2-r1.name
  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_route_table" "r1-azure-spoke-app2-aci-subnet-rt" {
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-${var.application_2}-aci-subnet-rt"
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

resource "azurerm_subnet_route_table_association" "app2-subnet-vm-2-rt-assoc" {
  route_table_id = azurerm_route_table.r1-azure-spoke-app2-vm-subnet-2-rt.id
  subnet_id      = azurerm_subnet.r1-azure-spoke-app2-vm-subnet-2.id
}

resource "azurerm_subnet_route_table_association" "app2-subnet-aci-rt-assoc" {
  route_table_id = azurerm_route_table.r1-azure-spoke-app2-aci-subnet-rt.id
  subnet_id      = azurerm_subnet.r1-azure-spoke-app2-aci-subnet.id
}

module "azr_r1_spoke_app2" {
  source = "terraform-aviatrix-modules/mc-spoke/aviatrix"

  cloud            = "Azure"
  name             = "azr-${var.azure_r1_location_short}-spoke-${var.application_2}-${var.customer_name}"
  vpc_id           = "${azurerm_virtual_network.azure-spoke-app2-r1.name}:${azurerm_resource_group.azr-r1-spoke-app2-rg.name}:${azurerm_virtual_network.azure-spoke-app2-r1.guid}"
  use_existing_vpc = true
  # # Comment when HPE is enabled
  gw_subnet   = azurerm_subnet.r1-azure-spoke-app2-gw-subnet.address_prefixes[0]
  hagw_subnet = azurerm_subnet.r1-azure-spoke-app2-hagw-subnet.address_prefixes[0]
  #  For HPE
  # gw_subnet   = "10.10.2.0/26"
  # hagw_subnet = "10.10.3.0/26"
  region     = var.azure_r1_location
  account    = var.azure_account
  transit_gw = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name
  attached   = true
  # For HPE ha_gw = true
  ha_gw = false
  //network_domain = aviatrix_segmentation_network_domain.dev_nd.domain_name
  single_ip_snat = false
  single_az_ha   = false
  resource_group = azurerm_resource_group.azr-r1-spoke-app2-rg.name
  # local_as_number = 65013
  enable_bgp    = false
  depends_on    = [azurerm_subnet_route_table_association.app2-subnet-aci-rt-assoc, azurerm_subnet_route_table_association.app2-subnet-vm-2-rt-assoc, azurerm_subnet_route_table_association.app2-subnet-vm-rt-assoc]
  instance_size = "Standard_B1ms"
  # insane_mode   = true # for HPE
  insane_mode = false
}

output "spoke_app2" {
  value     = module.azr_r1_spoke_app2
  sensitive = true
}

# resource "aviatrix_firewall" "spoke-fw" {
#   gw_name                  = module.azr_r1_spoke_app2.spoke_gateway.gw_name
#   manage_firewall_policies = false
#   //base_policy              = "deny-all"
#   base_policy      = "allow-all-off"
#   base_log_enabled = true
# }

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
  //vm_size             = "Standard_DS4_v2"
  depends_on = [
  ]
}

# module "we-app2-vm-2" {
#   source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
#   environment         = var.application_2
#   location            = var.azure_r1_location
#   location_short      = var.azure_r1_location_short
#   index_number        = 02
#   resource_group_name = azurerm_resource_group.azr-r1-spoke-app2-rg.name
#   subnet_id           = azurerm_subnet.r1-azure-spoke-app2-vm-subnet-2.id
#   admin_ssh_key       = var.ssh_public_key
#   depends_on = [
#   ]
# }



# resource "aviatrix_gateway_dnat" "DNAT_tcp9515" {
#   gw_name = module.azr_r1_spoke_app2.spoke_gateway.gw_name
#   dnat_policy {
#     src_cidr  = "0.0.0.0/0"
#     dst_port  = "8080"
#     protocol  = "tcp"
#     dnat_ips  = "10.10.2.164"
#     dnat_port = "8080"
#     connection = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name
#     interface = "eth0"
#   }
# }

# resource "azurerm_resource_group" "azr-r1-spoke-nat0-rg" {
#   location = var.azure_r1_location
#   name     = "azr-${var.azure_r1_location_short}-spoke-nat0-rg"
# }

# module "we_spoke_nat0_r1" {
#   source  = "terraform-aviatrix-modules/mc-overlap-nat-spoke/aviatrix"
#   version = "1.1.1"

#   spoke_gw_object = module.we_spoke_nat0.spoke_gateway
#   gw1_snat_addr   = "10.95.0.253"
#   gw2_snat_addr   = "10.95.0.254"

#   dnat_rules = {
#     in-aks-80 = {
#       dst_cidr  = "10.95.0.10/32",
#       dst_port  = "80",
#       protocol  = "tcp",
#       dnat_ips  = "10.99.0.52",
#       dnat_port = "80",
#     },
#     in-ssh-22 = {
#       dst_cidr  = "10.95.0.10/32",
#       dst_port  = "22",
#       protocol  = "tcp",
#       dnat_ips  = "10.99.0.52",
#       dnat_port = "22",
#     },
#     in-icmp = {
#       dst_cidr = "10.95.0.10/32",
#       protocol = "icmp",
#       dnat_ips = "10.99.0.52"
#     }
#   }

#   spoke_cidrs     = ["10.99.0.0/24"]
#   transit_gw_name = module.azure_transit_we.transit_gateway.gw_name
# }

# // nat0 SPOKE in R1
# resource "azurerm_virtual_network" "azure-spoke-nat0-r1" {
#   address_space       = ["10.99.0.0/24"]
#   location            = var.azure_r1_location
#   name                = "azr-${var.azure_r1_location_short}-spoke-nat0-vn"
#   resource_group_name = azurerm_resource_group.azr-r1-spoke-nat0-rg.name
# }

# resource "azurerm_subnet" "r1-azure-spoke-nat0-gw-subnet" {
#   address_prefixes     = ["10.99.0.0/28"]
#   name                 = "avx-gw-subnet"
#   resource_group_name  = azurerm_resource_group.azr-r1-spoke-nat0-rg.name
#   virtual_network_name = azurerm_virtual_network.azure-spoke-nat0-r1.name
# }

# resource "azurerm_subnet" "r1-azure-spoke-nat0-hagw-subnet" {
#   address_prefixes     = ["10.99.0.16/28"]
#   name                 = "avx-hagw-subnet"
#   resource_group_name  = azurerm_resource_group.azr-r1-spoke-nat0-rg.name
#   virtual_network_name = azurerm_virtual_network.azure-spoke-nat0-r1.name
# }

# resource "azurerm_subnet" "r1-azure-spoke-nat0-vm-subnet" {
#   address_prefixes     = ["10.99.0.32/28"]
#   name                 = "avx-vm-subnet"
#   resource_group_name  = azurerm_resource_group.azr-r1-spoke-nat0-rg.name
#   virtual_network_name = azurerm_virtual_network.azure-spoke-nat0-r1.name
# }

# resource "azurerm_subnet" "r1-azure-spoke-nat0-vm-public-subnet" {
#   address_prefixes     = ["10.99.0.48/28"]
#   name                 = "avx-vm-public-subnet"
#   resource_group_name  = azurerm_resource_group.azr-r1-spoke-nat0-rg.name
#   virtual_network_name = azurerm_virtual_network.azure-spoke-nat0-r1.name
# }

# resource "azurerm_route_table" "r1-azure-spoke-nat0-vm-subnet-rt" {
#   location            = var.azure_r1_location
#   name                = "azr-${var.azure_r1_location_short}-spoke-nat0-vm-subnet-rt"
#   resource_group_name = azurerm_resource_group.azr-r1-spoke-nat0-rg.name

#   route {
#     address_prefix = "0.0.0.0/0"
#     name           = "internetDefaultBlackhole"
#     next_hop_type  = "None"
#   }

#   lifecycle {
#     ignore_changes = [
#       route,
#     ]
#   }
# }

# resource "azurerm_subnet_route_table_association" "nat0-subnet-vm-rt-assoc" {
#   route_table_id = azurerm_route_table.r1-azure-spoke-nat0-vm-subnet-rt.id
#   subnet_id      = azurerm_subnet.r1-azure-spoke-nat0-vm-subnet.id
# }

# module "we_spoke_nat0" {
#   source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
#   version = "1.6.1"

#   cloud            = "Azure"
#   name             = "we-spoke-nat0"
#   vpc_id           = "${azurerm_virtual_network.azure-spoke-nat0-r1.name}:${azurerm_resource_group.azr-r1-spoke-nat0-rg.name}:${azurerm_virtual_network.azure-spoke-nat0-r1.guid}"
#   gw_subnet        = azurerm_subnet.r1-azure-spoke-nat0-gw-subnet.address_prefixes[0]
#   use_existing_vpc = true
#   hagw_subnet      = azurerm_subnet.r1-azure-spoke-nat0-hagw-subnet.address_prefixes[0]
#   region           = var.azure_r1_location
#   account          = local.accounts.azure_account
#   transit_gw       = module.azure_transit_we.transit_gateway.gw_name
#   ha_gw = false
#   //network_domain = aviatrix_segmentation_network_domain.nat0_nd.domain_name
#   single_az_ha                     = false
#   resource_group                   = azurerm_resource_group.azr-r1-spoke-nat0-rg.name
#   included_advertised_spoke_routes = "10.95.0.253/32,10.95.0.254/32,10.95.0.10/32"
# }

# module "we-app-nat0-vm" {
#   source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
#   environment         = "app-nat0"
#   location            = var.azure_r1_location
#   location_short      = var.azure_r1_location_short
#   index_number        = 01
#   resource_group_name = azurerm_resource_group.avx-lab-vms-rg.name
#   subnet_id           = azurerm_subnet.r1-azure-spoke-nat0-vm-public-subnet.id
#   admin_ssh_key       = var.ssh_public_key
#   depends_on = [
#     module.we_spoke_nat0
#   ]
# }

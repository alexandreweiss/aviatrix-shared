resource "azurerm_resource_group" "azr-r1-spoke-app-b-microseg-rg" {
  location = var.azure_r1_location
  name     = "azr-${var.azure_r1_location_short}-spoke-app-b-microseg-rg"
}

# resource "azurerm_virtual_network" "r1-spoke-app-b" {
#   address_space       = ["10.30.5.0/24"]
#   location            = var.azure_r1_location
#   name                = "${var.azure_r1_location_short}-spoke-app-b"
#   resource_group_name = azurerm_resource_group.azr-r1-spoke-app-b-microseg-rg.name
# }

# resource "azurerm_subnet" "r1-spoke-app-b-avx-gw-subnet" {
#   address_prefixes     = ["10.30.5.0/28"]
#   name                 = "avx-gw-subnet"
#   resource_group_name  = azurerm_resource_group.azr-r1-spoke-app-b-microseg-rg.name
#   virtual_network_name = azurerm_virtual_network.r1-spoke-app-b.name
# }

# resource "azurerm_subnet" "r1-spoke-app-b-avx-hagw-subnet" {
#   address_prefixes     = ["10.30.5.16/28"]
#   name                 = "avx-hagw-subnet"
#   resource_group_name  = azurerm_resource_group.azr-r1-spoke-app-b-microseg-rg.name
#   virtual_network_name = azurerm_virtual_network.r1-spoke-app-b.name
# }

# resource "azurerm_subnet" "app-b-prd-front-subnet" {
#   address_prefixes     = ["10.30.5.32/28"]
#   name                 = "prd-front-subnet"
#   resource_group_name  = azurerm_resource_group.azr-r1-spoke-app-b-microseg-rg.name
#   virtual_network_name = azurerm_virtual_network.r1-spoke-app-b.name
# }


# resource "azurerm_subnet" "app-b-prd-sc-subnet" {
#   address_prefixes     = ["10.30.5.48/28"]
#   name                 = "prd-sc-subnet"
#   resource_group_name  = azurerm_resource_group.azr-r1-spoke-app-b-microseg-rg.name
#   virtual_network_name = azurerm_virtual_network.r1-spoke-app-b.name
# }

# resource "azurerm_subnet" "app-b-prd-sql-subnet" {
#   address_prefixes     = ["10.30.5.64/28"]
#   name                 = "prd-sql-subnet"
#   resource_group_name  = azurerm_resource_group.azr-r1-spoke-app-b-microseg-rg.name
#   virtual_network_name = azurerm_virtual_network.r1-spoke-app-b.name
# }

# resource "azurerm_route_table" "app-r1-spoke-app-b-rt" {
#   location            = var.azure_r1_location
#   name                = "${var.azure_r1_location_short}-azr-r1-spoke-app-b-microseg-rt"
#   resource_group_name = azurerm_resource_group.azr-r1-spoke-app-b-microseg-rg.name

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

# resource "azurerm_subnet_route_table_association" "azr-r1-spoke-microseg-app-b-rt-assoc" {
#   route_table_id = azurerm_route_table.app-r1-spoke-app-b-rt.id
#   subnet_id      = azurerm_subnet.app-b-prd-sc-subnet.id
# }

# resource "aviatrix_spoke_gateway" "azr-r1-spoke-microseg-app-b-gw" {
#   cloud_type   = 8
#   account_name = var.azure_account
#   gw_name      = "${var.azure_r1_location_short}-app-b-spoke"
#   vpc_id       = "${azurerm_virtual_network.r1-spoke-app-b.name}:${azurerm_resource_group.azr-r1-spoke-app-b-microseg-rg.name}:${azurerm_virtual_network.r1-spoke-app-b.guid}"
#   //vpc_reg           = azurerm_virtual_network.r1-spoke-app-b.location
#   vpc_reg           = var.azure_r1_location
#   gw_size           = "Standard_B1ms"
#   subnet            = "10.30.5.0/28"
#   single_ip_snat    = false
#   manage_ha_gateway = false
#   depends_on        = [azurerm_virtual_network.r1-spoke-app-b]
# }

# resource "aviatrix_spoke_transit_attachment" "spoke-app-b-transit-attachement" {
#   spoke_gw_name   = aviatrix_spoke_gateway.azr-r1-spoke-microseg-app-b-gw.gw_name
#   transit_gw_name = module.azure_transit_we.transit_gateway.gw_name
#   #   route_tables = [
#   #     "rtb-737d540c",
#   #     "rtb-626d045c"
#   #   ]
# }

# module "r1-app-b-front-vm" {
#   source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
#   environment         = "front-app-b"
#   location            = var.azure_r1_location
#   location_short      = var.azure_r1_location_short
#   index_number        = 01
#   resource_group_name = azurerm_resource_group.azr-r1-spoke-app-b-microseg-rg.name
#   subnet_id           = azurerm_subnet.prd-front-subnet.id
#   admin_ssh_key       = var.ssh_public_key
#   vm_size             = "Standard_B1ms"
# }

# module "r1-app-b-2-front-vm" {
#   source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
#   environment         = "front-app-b-2"
#   location            = var.azure_r1_location
#   location_short      = var.azure_r1_location_short
#   index_number        = 01
#   resource_group_name = azurerm_resource_group.azr-r1-spoke-app-b-microseg-rg.name
#   subnet_id           = azurerm_subnet.prd-front-subnet.id
#   admin_ssh_key       = var.ssh_public_key
#   vm_size             = "Standard_B1ms"
# }

# module "r1-app-b-sc-vm" {
#   source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
#   environment         = "sc-app-b"
#   location            = var.azure_r1_location
#   location_short      = var.azure_r1_location_short
#   index_number        = 01
#   resource_group_name = azurerm_resource_group.azr-r1-spoke-app-b-microseg-rg.name
#   subnet_id           = azurerm_subnet.prd-sc-subnet.id
#   admin_ssh_key       = var.ssh_public_key
#   vm_size             = "Standard_B1ms"
# }

# module "r1-app-b-sql-vm" {
#   source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
#   environment         = "sql-app-b"
#   location            = var.azure_r1_location
#   location_short      = var.azure_r1_location_short
#   index_number        = 01
#   resource_group_name = azurerm_resource_group.azr-r1-spoke-app-b-microseg-rg.name
#   subnet_id           = azurerm_subnet.prd-sql-subnet.id
#   admin_ssh_key       = var.ssh_public_key
#   vm_size             = "Standard_B1ms"
# }

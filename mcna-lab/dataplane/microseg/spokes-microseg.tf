resource "azurerm_resource_group" "azr-r1-spoke-microseg-rg" {
  location = var.azure_r1_location
  name     = "azr-${var.azure_r1_location_short}-spoke-microseg-rg"
}

# resource "azurerm_virtual_network" "r1-spoke-app" {
#   address_space       = ["10.30.4.0/24"]
#   location            = var.azure_r1_location
#   name                = "${var.azure_r1_location_short}-spoke-app"
#   resource_group_name = azurerm_resource_group.azr-r1-spoke-microseg-rg.name
# }

# resource "azurerm_subnet" "r1-spoke-avx-gw-subnet" {
#   address_prefixes     = ["10.30.4.0/28"]
#   name                 = "avx-gw-subnet"
#   resource_group_name  = azurerm_resource_group.azr-r1-spoke-microseg-rg.name
#   virtual_network_name = azurerm_virtual_network.r1-spoke-app.name
# }

# resource "azurerm_subnet" "r1-spoke-avx-hagw-subnet" {
#   address_prefixes     = ["10.30.4.16/28"]
#   name                 = "avx-hagw-subnet"
#   resource_group_name  = azurerm_resource_group.azr-r1-spoke-microseg-rg.name
#   virtual_network_name = azurerm_virtual_network.r1-spoke-app.name
# }

# resource "azurerm_subnet" "prd-front-subnet" {
#   address_prefixes     = ["10.30.4.32/28"]
#   name                 = "prd-front-subnet"
#   resource_group_name  = azurerm_resource_group.azr-r1-spoke-microseg-rg.name
#   virtual_network_name = azurerm_virtual_network.r1-spoke-app.name
# }


# resource "azurerm_subnet" "prd-sc-subnet" {
#   address_prefixes     = ["10.30.4.48/28"]
#   name                 = "prd-sc-subnet"
#   resource_group_name  = azurerm_resource_group.azr-r1-spoke-microseg-rg.name
#   virtual_network_name = azurerm_virtual_network.r1-spoke-app.name
# }

# resource "azurerm_subnet" "prd-sql-subnet" {
#   address_prefixes     = ["10.30.4.64/28"]
#   name                 = "prd-sql-subnet"
#   resource_group_name  = azurerm_resource_group.azr-r1-spoke-microseg-rg.name
#   virtual_network_name = azurerm_virtual_network.r1-spoke-app.name
# }

# resource "azurerm_route_table" "app-r1-spoke-rt" {
#   location            = var.azure_r1_location
#   name                = "${var.azure_r1_location_short}-azr-r1-spoke-microseg-rt"
#   resource_group_name = azurerm_resource_group.azr-r1-spoke-microseg-rg.name

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

# resource "azurerm_subnet_route_table_association" "azr-r1-spoke-microseg-rt-assoc" {
#   route_table_id = azurerm_route_table.app-r1-spoke-rt.id
#   subnet_id      = azurerm_subnet.prd-sc-subnet.id
# }

# resource "aviatrix_spoke_gateway" "azr-r1-spoke-microseg-gw" {
#   cloud_type   = 8
#   account_name = local.accounts.azure_account
#   gw_name      = "${var.azure_r1_location_short}-app-spoke"
#   vpc_id       = "${azurerm_virtual_network.r1-spoke-app.name}:${azurerm_resource_group.azr-r1-spoke-microseg-rg.name}:${azurerm_virtual_network.r1-spoke-app.guid}"
#   //vpc_reg           = azurerm_virtual_network.r1-spoke-app.location
#   vpc_reg           = var.azure_r1_location
#   gw_size           = "Standard_B1ms"
#   subnet            = "10.30.4.0/28"
#   single_ip_snat    = false
#   manage_ha_gateway = false
#   depends_on        = [azurerm_virtual_network.r1-spoke-app]
# }

# resource "aviatrix_spoke_transit_attachment" "spoke-transit-attachement" {
#   spoke_gw_name   = aviatrix_spoke_gateway.azr-r1-spoke-microseg-gw.gw_name
#   transit_gw_name = module.azure_transit_we.transit_gateway.gw_name
#   #   route_tables = [
#   #     "rtb-737d540c",
#   #     "rtb-626d045c"
#   #   ]
# }

# module "r1-app-front-vm" {
#   source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
#   environment         = "front-app"
#   location            = var.azure_r1_location
#   location_short      = var.azure_r1_location_short
#   index_number        = 01
#   resource_group_name = azurerm_resource_group.azr-r1-spoke-microseg-rg.name
#   subnet_id           = azurerm_subnet.prd-front-subnet.id
#   admin_ssh_key       = var.ssh_public_key
#   vm_size             = "Standard_B1ms"
# }

# module "r1-app-2-front-vm" {
#   source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
#   environment         = "front-app-2"
#   location            = var.azure_r1_location
#   location_short      = var.azure_r1_location_short
#   index_number        = 01
#   resource_group_name = azurerm_resource_group.azr-r1-spoke-microseg-rg.name
#   subnet_id           = azurerm_subnet.prd-front-subnet.id
#   admin_ssh_key       = var.ssh_public_key
#   vm_size             = "Standard_B1ms"
# }

# module "r1-app-sc-vm" {
#   source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
#   environment         = "sc-app"
#   location            = var.azure_r1_location
#   location_short      = var.azure_r1_location_short
#   index_number        = 01
#   resource_group_name = azurerm_resource_group.azr-r1-spoke-microseg-rg.name
#   subnet_id           = azurerm_subnet.prd-sc-subnet.id
#   admin_ssh_key       = var.ssh_public_key
#   vm_size             = "Standard_B1ms"
# }

# module "r1-app-sql-vm" {
#   source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
#   environment         = "sql-app"
#   location            = var.azure_r1_location
#   location_short      = var.azure_r1_location_short
#   index_number        = 01
#   resource_group_name = azurerm_resource_group.azr-r1-spoke-microseg-rg.name
#   subnet_id           = azurerm_subnet.prd-sql-subnet.id
#   admin_ssh_key       = var.ssh_public_key
#   vm_size             = "Standard_B1ms"
# }


# output "vms_private_ips" {
#   value = {
#     "sql_vm_private_ip"         = module.r1-app-sql-vm.vm_private_ip,
#     "sc_vm_private_ip"          = module.r1-app-sc-vm.vm_private_ip,
#     "front_app_vm_private_ip"   = module.r1-app-front-vm.vm_private_ip
#     "front_app_2_vm_private_ip" = module.r1-app-2-front-vm.vm_private_ip
#   }
#   description = "private IPs of test VMs"
# }

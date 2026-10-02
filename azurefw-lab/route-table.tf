# Route Table
resource "azurerm_route_table" "vm_route_table" {
  name                = "rt-vm-subnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  route {
    name           = "route-to-firewall"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.main.ip_configuration[0].private_ip_address
  }
}

# Associate route table with VM subnet
resource "azurerm_subnet_route_table_association" "vm_subnet_rt" {
  subnet_id      = azurerm_subnet.vm_subnet.id
  route_table_id = azurerm_route_table.vm_route_table.id
}

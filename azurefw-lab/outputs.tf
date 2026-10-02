output "firewall_private_ip" {
  value = azurerm_firewall.main.ip_configuration[0].private_ip_address
}

output "firewall_public_ip" {
  value = azurerm_public_ip.firewall_pip.ip_address
}

output "vm_public_ip" {
  value = azurerm_public_ip.vm_pip.ip_address
}

output "vm_private_ip" {
  value = azurerm_network_interface.vm_nic.private_ip_address
}

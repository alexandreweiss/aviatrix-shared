output "vpn-public-ip-0" {
  value = azurerm_public_ip.pip_0.ip_address
}

output "vpn-public-ip-1" {
  value = azurerm_public_ip.pip_1.ip_address
}

output "bgp-ip" {
  value = azurerm_virtual_network_gateway.vpn-gw.bgp_settings
}

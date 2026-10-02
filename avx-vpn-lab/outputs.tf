output "vpn-public-ip" {
  value = azurerm_public_ip.pip.ip_address
}

output "bgp-ip" {
  value = azurerm_virtual_network_gateway.vpn-gw.bgp_settings
}

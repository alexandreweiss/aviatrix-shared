output "vpn-public-ip" {
  value = module.vpn_gw.vpn_gateway_public_ip
}

output "bgp_settings" {
  value = module.vpn_gw.vpn_gateway.bgp_settings
}

# Segmentation aka. "Network Domain"

module "mc-network-domains" {
  source = "terraform-aviatrix-modules/mc-network-domains/aviatrix"
  //version = "1.0.0"

  # connection_policies = [
  #   ["sdwan1"],
  #   ["sdwan2"],
  #   ["vpn"]
  # ]
  manage_network_domains = true

  additional_domains = [
    "sdwan1",
    "sdwan2",
    "vpn"
  ]

}

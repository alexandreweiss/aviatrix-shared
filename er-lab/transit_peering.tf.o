module "transit-peering" {
  source  = "terraform-aviatrix-modules/mc-transit-peering/aviatrix"
  version = "1.0.9"

  transit_gateways = [
    module.azure_transit_ars.transit_gateway.gw_name,
    module.aws_transit_r1.transit_gateway.gw_name
  ]

  excluded_cidrs = [
    "0.0.0.0/0",
  ]
}

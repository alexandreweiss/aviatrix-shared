module "transit_peering" {
  source  = "terraform-aviatrix-modules/mc-transit-peering/aviatrix"
  version = "1.0.8"

  transit_gateways = [
    module.azure_transit_we.transit_gateway.gw_name,
    //module.azure_transit_ne.transit_gateway.gw_name,
    //module.aws_transit_fra.transit_gateway.gw_name
  ]
}

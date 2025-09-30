module "transit_peering" {
  source = "terraform-aviatrix-modules/mc-transit-peering/aviatrix"

  transit_gateways = [
    module.azure_transit_oai.transit_gateway.gw_name,
    module.aws_transit_oai.transit_gateway.gw_name
  ]
}

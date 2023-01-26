# data "aviatrix_vpc" "we_spoke_prd" {
#   name = module.we_spoke_prd[0].vpc.name
#   depends_on = [
#     module.we_spoke_prd
#   ]
# }

# data "aviatrix_vpc" "we_spoke_dev" {
#   name = module.we_spoke_dev[0].vpc.name
#   depends_on = [
#     module.we_spoke_dev
#   ]
# }

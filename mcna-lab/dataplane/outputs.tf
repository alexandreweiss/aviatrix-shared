# output "w365_subnet" {
#   value = data.aviatrix_vpc.we_spoke_prd.route_tables
# }

output "vms_private_ips" {
  value = {
    "sql_vm_private_ip"         = module.r1-app-sql-vm.vm_private_ip,
    "sc_vm_private_ip"          = module.r1-app-sc-vm.vm_private_ip,
    "front_app_vm_private_ip"   = module.r1-app-front-vm.vm_private_ip
    "front_app_2_vm_private_ip" = module.r1-app-2-front-vm.vm_private_ip
  }
  description = "private IPs of test VMs"
}

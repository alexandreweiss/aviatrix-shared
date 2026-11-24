# More Gatus probe sources (small VMs in MyApp1, each with its own private IP) and one
# dashboard VM that aggregates them with Gatus "remote instances". Private only, reachable
# over the Aviatrix dataplane. (ACI cannot be used: the MyApp1 VNet is dual-stack.)

variable "enable_gatus_fleet" {
  description = "Deploy the Gatus test fleet (13 source VMs + dashboard + the original Gatus VM). Off by default; destroyed after the Cato tests."
  type        = bool
  default     = false
}

variable "gatus_src_count" {
  description = "Number of additional Gatus probe source VMs"
  type        = number
  default     = 6
}

module "we-app1-gatus-src" {
  count       = var.enable_gatus_fleet ? var.gatus_src_count : 0
  source      = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  environment = var.application_1
  tags = {
    "application" = var.application_1
    "role"        = "gatus-source"
  }
  location             = var.azure_r1_location
  location_short       = var.azure_r1_location_short
  index_number         = 10 + count.index
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-app1-rg.name
  subnet_id            = azurerm_subnet.r1-azure-spoke-app1-vm-subnet-2.id
  admin_ssh_key        = var.ssh_public_key
  customer_name        = var.customer_name
  enable_auto_shutdown = false
  custom_data          = base64encode(file("${path.module}/app1_gatus_cloud-init.yaml"))

  depends_on = [azurerm_subnet_route_table_association.app1-subnet-vm-2-rt-assoc]
}

module "we-app1-gatus-dash" {
  count       = var.enable_gatus_fleet ? 1 : 0
  source      = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  environment = var.application_1
  tags = {
    "application" = var.application_1
    "role"        = "gatus-dashboard"
  }
  location             = var.azure_r1_location
  location_short       = var.azure_r1_location_short
  index_number         = 20
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-app1-rg.name
  subnet_id            = azurerm_subnet.r1-azure-spoke-app1-vm-subnet-2.id
  admin_ssh_key        = var.ssh_public_key
  customer_name        = var.customer_name
  enable_auto_shutdown = false
  custom_data = base64encode(templatefile("${path.module}/app1_gatus_dashboard_cloud-init.yaml", {
    sources = merge(
      { vm = module.we-app1-gatus-vm[0].vm_private_ip },
      { for i, m in module.we-app1-gatus-src : "src${i + 1}" => m.vm_private_ip },
      { for i, m in module.we-app2-gatus-src : "m2src${i + 1}" => m.vm_private_ip }
    )
  }))

  depends_on = [azurerm_subnet_route_table_association.app1-subnet-vm-2-rt-assoc]
}

output "gatus_dashboard_url" {
  value       = var.enable_gatus_fleet ? "http://${module.we-app1-gatus-dash[0].vm_private_ip}" : null
  description = "Single Gatus dashboard for all sources (private, over the Aviatrix dataplane)"
}

output "gatus_source_ips" {
  value = var.enable_gatus_fleet ? merge(
    { vm = module.we-app1-gatus-vm[0].vm_private_ip },
    { for i, m in module.we-app1-gatus-src : "src${i + 1}" => m.vm_private_ip }
  ) : {}
}

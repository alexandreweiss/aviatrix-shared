# Reverse Gatus probe sources: VMs in MyApp2 probing the transit gateways' internal IPs and the
# MyApp1 Gatus VM (ICMP + TCP). Aggregated by the single dashboard in MyApp1
# (see app1_gatus_sources.tf). Private only.

variable "gatus_m2_count" {
  description = "Number of Gatus probe source VMs in MyApp2"
  type        = number
  default     = 6
}

module "we-app2-gatus-src" {
  count       = var.enable_gatus_fleet ? var.gatus_m2_count : 0
  source      = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  environment = var.application_2
  tags = {
    "application" = var.application_2
    "role"        = "gatus-source"
  }
  location             = var.azure_r1_location
  location_short       = var.azure_r1_location_short
  index_number         = 10 + count.index
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-app2-rg.name
  subnet_id            = azurerm_subnet.r1-azure-spoke-app2-vm-subnet.id
  admin_ssh_key        = var.ssh_public_key
  customer_name        = var.customer_name
  enable_auto_shutdown = false
  custom_data          = base64encode(file("${path.module}/app2_gatus_cloud-init.yaml"))

  depends_on = [azurerm_subnet_route_table_association.app2-subnet-vm-rt-assoc]
}

output "gatus_m2_source_ips" {
  value = { for i, m in module.we-app2-gatus-src : "m2src${i + 1}" => m.vm_private_ip }
}

variable "r1_location" {
  description = "Region 1 location"
  default     = "westeurope"
}

variable "r1_location_short" {
  description = "Short name of Region 1"
  default     = "we"
}

variable "ssh_public_key" {
  sensitive   = true
  description = "Linux SSH public key"
}

data "dns_a_record_set" "controller_ip" {
  host = var.controller_fqdn
}

variable "controller_fqdn" {
  description = "FQDN or IP of the Aviatrix Controller"
}

variable "admin_password" {
  sensitive   = true
  description = "Admin password"
}

locals {
  data = jsondecode(file("${path.module}/vwan-configuration.json"))
}

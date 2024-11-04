variable "azure_r1_location" {
  description = "Region 1 location"
  default     = "francecentral"
}

variable "azure_r1_location_short" {
  description = "Short name of Region 1"
  default     = "frc"
}

# variable "ssh_public_key" {
#   sensitive   = true
#   description = "Linux SSH public key"
# }

# data "dns_a_record_set" "controller_ip" {
#   host = var.controller_fqdn
# }

# variable "controller_fqdn" {
#   description = "FQDN or IP of the Aviatrix Controller"
# }

# variable "admin_password" {
#   sensitive   = true
#   description = "Admin password"
# }

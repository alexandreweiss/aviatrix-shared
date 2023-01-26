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

locals {
  data = jsondecode(file("${path.module}/vwan-configuration.json"))
}

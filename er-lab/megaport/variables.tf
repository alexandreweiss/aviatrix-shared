variable "access_key" {
  description = "The access key to the Megaport API"
  sensitive   = true
}

variable "secret_key" {
  description = "The secret key of the MegaPort API"
  sensitive   = true
}

variable "azure_r1_location" {
  default     = "West Europe"
  description = "region to deploy resources"
  type        = string
}

variable "azure_r1_location_short" {
  default     = "we"
  description = "region to deploy resources"
  type        = string
}

variable "private_peering_vlanid" {
  description = "Azure Express Route Private Peering VLAN ID"
  type        = string
  default     = 100
}

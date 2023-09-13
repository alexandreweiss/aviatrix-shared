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

variable "azure_r2_location" {
  default     = "North Europe"
  description = "region to deploy resources"
  type        = string
}

variable "azure_r2_location_short" {
  default     = "ne"
  description = "region to deploy resources"
  type        = string
}

variable "packet_fabric_api_key" {
  description = "API Key to access Packet Fabric"
  sensitive   = true
}

variable "packet_fabric_account_id" {
  description = "Username/account_id to access Packet Fabric"
  sensitive   = true
}

# variable "packet_fabric_router_port" {
#   description = "Port on the router to connect to"
# }

variable "private_peering_vlan_id" {
  description = "VLAN ID of the private peering"
  default     = 3999
}

variable "ssh_public_key" {
  sensitive   = true
  description = "SSH public key for VM administration"
}

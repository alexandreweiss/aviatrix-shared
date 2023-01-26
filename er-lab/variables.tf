variable "packet_fabric_api_key" {
  description = "API Key to access Packet Fabric"
  sensitive   = true
}

variable "packet_fabric_account_id" {
  description = "Username/account_id to access Packet Fabric"
  sensitive   = true
}

variable "packet_fabric_router_port" {
  description = "Port on the router to connect to"
}

variable "private_peering_vlan_id" {
  description = "VLAN ID of the private peering"
  default     = 3999
}

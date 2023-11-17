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

variable "aws_r1_location" {
  default     = "eu-central-1"
  description = "region to deploy resources"
  type        = string
}

variable "aws_r1_location_short" {
  default     = "fra"
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

variable "admin_password" {
  sensitive   = true
  description = "Admin password"
}

variable "controller_fqdn" {
  description = "FQDN or IP of the Aviatrix Controller"
  sensitive   = true
}

variable "azure_account" {
  description = "CSP account onboarder on the controller"
}

variable "aws_account" {
  description = "CSP account onboarder on the controller"
}

variable "pre_shared_key" {
  description = "Pre shared key used in IPSEC tunnels"
}

variable "packet_fabric_ipsec_ip_address" {
  description = "IP address of PacketFabric IPSEC onramp"
  default     = "23.159.0.152"
}

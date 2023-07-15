variable "azure_r1_location" {
  default     = "France Central"
  description = "region to deploy resources"
  type        = string
}

variable "azure_r1_location_short" {
  default     = "fr"
  description = "region to deploy resources"
  type        = string
}

variable "node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  default     = 1
}

variable "msi_id" {
  type        = string
  description = "The Managed Service Identity ID. Set this value if you're running this example using Managed Identity as the authentication method."
  default     = null
}

variable "ssh_public_key" {
  sensitive   = true
  description = "SSH public key for VM administration"
}

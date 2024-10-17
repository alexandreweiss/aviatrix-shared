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

variable "oci_tenant_id" {
  description = "value of the tenant id"
  sensitive   = true
}

variable "oci_user_id" {
  description = "value of the user id"
  sensitive   = true
}

variable "oci_private_key" {
  description = "content of the private key file"
  sensitive   = true
}

variable "oci_comp_id" {
  description = "value of the compartment id"
}

variable "ssh_public_key" {
  sensitive   = true
  description = "SSH public key for VM administration"
}

variable "deploy_er_connection" {
  description = "deploy ER connection"
  type        = bool
  default     = false
}

variable "deploy_er_circuit" {
  description = "deploy ER circuit"
  type        = bool
  default     = true
}
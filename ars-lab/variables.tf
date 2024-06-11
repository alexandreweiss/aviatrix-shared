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

variable "transit_gw_eth3_bgp_ip" {
  description = "BGP Peer IP of the first Aviatrix gateway"
  default     = "10.10.0.116"
}

variable "transit_hagw_eth3_bgp_ip" {
  description = "BGP Peer IP of the first Aviatrix gateway"
  default     = "10.10.0.140"
}

variable "asn_fw" {
  description = "ASN to be used by FW / FRR"
  default     = 65000
}

variable "asn_transit" {
  description = "ASN to be used by FW / FRR"
  default     = 65007
}

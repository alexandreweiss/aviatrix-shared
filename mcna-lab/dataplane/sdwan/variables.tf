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

variable "gcp_account" {
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

variable "transit_gw_eth4_bgp_ip" {
  description = "BGP Peer IP of the first Aviatrix gateway"
  default     = "10.10.0.124"
}

variable "transit_hagw_eth4_bgp_ip" {
  description = "BGP Peer IP of the first Aviatrix gateway"
  default     = "10.10.0.180"
}

variable "asn_sdwan" {
  description = "ASN to be used by SDWAN / Quagga"
  default     = 65000
}

variable "asn_transit" {
  description = "ASN to be used by SDWAN / Quagga"
  default     = 65007
}

locals {
  controller = {
    controller_vnet_name           = "avx-ctrl-ne-vnet"
    controller_resource_group_name = "avx-ctrl-ne-rg"
  }
}

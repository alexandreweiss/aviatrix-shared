variable "azure_we_location" {
  default     = "West Europe"
  description = "region to deploy resources"
  type        = string
}

variable "azure_we_location_short" {
  default     = "we"
  description = "region to deploy resources"
  type        = string
}

variable "azure_ne_location" {
  default     = "North Europe"
  description = "region to deploy resources"
  type        = string
}

variable "azure_ne_location_short" {
  default     = "ne"
  description = "region to deploy resources"
  type        = string
}

variable "gcp_we_location" {
  default     = "europe-west1"
  description = "region to deploy resources"
  type        = string
}

variable "gcp_we_location_short" {
  default     = "we"
  description = "region to deploy resources"
  type        = string
}

variable "aws_we_location" {
  default     = "europe-west1"
  description = "region to deploy resources"
  type        = string
}

variable "aws_we_location_short" {
  default     = "we"
  description = "region to deploy resources"
  type        = string
}

variable "core_resource_group_name" {
  default     = "avs-lab-core-rg"
  description = "Name of the resource group for core resources like DNS ..."
}

variable "ferme_fqdn" {
  description = "FQDN of Ferme ISP"
  sensitive   = true
}

variable "ferme_psk" {
  description = "PSK of Ferme S2C connection"
  sensitive   = true
}

variable "admin_username" {
  default     = "admin"
  description = "administrator username"
}

variable "firewall_admin_username" {
  default     = "admin-lab"
  description = "administrator username of the firewall"
}

variable "admin_password" {
  sensitive   = true
  description = "Admin password"
}

variable "ssh_public_key" {
  sensitive   = true
  description = "SSH public key for VM administration"
}

variable "controller_ip" {
  description = "FQDN or IP of the Aviatrix Controller"
  sensitive   = true
}

variable "p2s_additional_cidrs" {
  default     = "10.0.0.0/8,192.168.10.0/24,1.1.1.1/32,192.168.16.0/23"
  description = "Split tunneling for P2S users"
}

locals {
  accounts = {
    azure_account = "azr-alweiss"
    gcp_account   = "gcp-alweiss"
  }

  controller = {
    controller_vnet_name           = "avx-ctrl-we-vnet"
    controller_resource_group_name = "avx-ctrl-we-rg"
  }

  features = {
    //VPN
    deploy_azr_vpn_gw    = true
    deploy_azr_vpn_spoke = true
    // AZR Bastion
    deploy_azr_bastion = false
    // North Europe AZR
    deploy_azr_ne_spoke = false
    // West Europe AZR
    deploy_azr_we_spoke_prd = true
    deploy_azr_we_spoke_dev = true
    // West Europe GCP
    deploy_gcp_we_spoke = false
    // W365 spoke
    deploy_azr_we_spoke_w365 = true
  }
}

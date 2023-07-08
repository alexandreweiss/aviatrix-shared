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

variable "admin_password" {
  sensitive   = true
  description = "Admin password"
}

variable "controller_fqdn" {
  description = "FQDN or IP of the Aviatrix Controller"
  sensitive   = true
}

variable "ferme_fqdn" {
  description = "FQDN of Ferme ISP"
  sensitive   = true
}

variable "ssh_public_key" {
  sensitive   = true
  description = "SSH public key for VM administration"
}

locals {
  accounts = {
    azure_account = "azure-alweiss"
    aws_account   = "aws-alweiss"
    gcp_account   = "gcp-alweiss"
  }
}

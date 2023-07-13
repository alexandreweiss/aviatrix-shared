variable "ferme_fqdn" {
  description = "FQDN of Ferme ISP"
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

variable "controller_vnet_cidr" {
  default = "192.168.10.0/24"
}

variable "controller_subnet_cidr" {
  default = "192.168.10.0/28"
}

variable "controller_virtual_machine_size" {
  default = "Standard_B2ms"
}

variable "copilot_virtual_machine_size" {
  default = "Standard_B2ms"
}

variable "admin_password" {
  sensitive   = true
  description = "Administrator password"
}

variable "admin_email" {
  sensitive   = true
  description = "Administrator email"
}

variable "aviatrix_customer_id" {
  sensitive   = true
  description = "License ID"
}

locals {

  copilot = {
    username = "admin-lab"
  }

  accounts = {
    azure_account = "azure-alweiss"
    aws_account   = "aws-alweiss"
  }
}

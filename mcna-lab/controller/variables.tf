variable "azure_we_location" {
    default = "North Europe"
    description = "region to deploy resources"
    type = string
}

variable "azure_ne_location" {
    default = "North Europe"
    description = "region to deploy resources"
    type = string
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

variable "admin_password" {
  sensitive = true
  description = "Administrator password"
}

variable "aviatrix_customer_id" {
  sensitive = true
  description = "License ID"
}

locals {
  controller = {
    username = "admin"
    admin_email = "aweiss@aviatrix.com"
  }

  copilot    = {
    username = "admin-lab"
  }

  accounts = {
    azure_account = "azure-alweiss"
    aws_account = "aws-alweiss"
  }
}

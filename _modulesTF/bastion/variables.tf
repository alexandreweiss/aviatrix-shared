variable "location" {
  default = "West Europe"
  description = "Region to deploy the VM to"
}

variable "location_short" {
  default = "we"
  description = "Region to deploy the VM to"
}

variable "resource_group_name" {
  description = "RG to deploy resource to"
}

variable "subnet_id" {
  description = "Subnet to deploy bastion to"
}

locals {
  bastion = {
    bastion_name = "${var.location_short}-bastion"
    pip_name = "${var.location_short}-bastion-pip"
  }
}
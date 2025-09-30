variable "azure_r1_location" {
  description = "Region 1 location"
  default     = "East US"
}

variable "azure_r1_location_short" {
  description = "Short name of Region 1"
  default     = "eus"
}

variable "aws_r1_location" {
  description = "Region 1 location"
  default     = "eu-central-1"
}

variable "aws_r1_location_short" {
  description = "Short name of Region 1"
  default     = "fra"
}

variable "azure_oai_location" {
  description = "OAI location"
  default     = "Canada East"

}

variable "azure_oai_location_short" {
  description = "OAI location"
  default     = "cea"

}

variable "azure_account" {
  description = "Azure account name"
}

variable "aws_account" {
  description = "CSP account onboarder on the controller"
}

# variable "ssh_public_key" {
#   sensitive   = true
#   description = "Linux SSH public key"
# }

# data "dns_a_record_set" "controller_ip" {
#   host = var.controller_fqdn
# }

variable "controller_fqdn" {
  description = "FQDN or IP of the Aviatrix Controller"
}

variable "admin_password" {
  sensitive   = true
  description = "Admin password"
}

variable "admin_username" {
  description = "Admin username"
}

locals {
  subnets = {
    avx-gw-subnet = {
      route_table = "avx-gw",
      # cidr              = cidrsubnet(var.gw_subnet, 1, 0)
      cidr              = cidrsubnet(var.gw_subnet, 4, 8)
      availability_zone = "${var.aws_r1_location}a"
    },
    avx-hagw-subnet = {
      route_table = "avx-hagw",
      # cidr              = cidrsubnet(var.gw_subnet, 1, 1)
      cidr              = cidrsubnet(var.gw_subnet, 4, 9)
      availability_zone = "${var.aws_r1_location}c"
    },
    front-a = {
      route_table       = "rt-internal-a",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 0)
      availability_zone = "${var.aws_r1_location}a"
    }
  }
}

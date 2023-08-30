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

variable "aks_cluster_qty" {
  type        = number
  description = "Number of AKS cluster to deploy"
  default     = 1
}

variable "vnet_address_space" {
  description = "Address space of vnet to create. First is for node, infra, service. Second is for non routable PODs"
  type = list(object({
    infra_cidr = string
    pod_cidr   = string
  }))

  default = [
    {
      "infra_cidr" = "172.19.18.0/23",
      "pod_cidr"   = "100.64.0.0/16"
    },
    {
      "infra_cidr" = "172.19.20.0/23",
      "pod_cidr"   = "100.64.0.0/16"
    },
    {
      "infra_cidr" = "172.19.22.0/23",
      "pod_cidr"   = "100.64.0.0/16"
    }
  ]
}

variable "internal_service_address_space" {
  description = "Address space used for internal cluster services"
  default     = "172.16.0.0/16"
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

variable "azure_account" {
  description = "CSP account onboarder on the controller"
}

variable "aws_account" {
  description = "CSP account onboarder on the controller"
}

variable "gcp_account" {
  description = "CSP account onboarder on the controller"
}

variable "ferme_fqdn" {
  description = "FQDN of Ferme ISP"
  sensitive   = true
}

variable "admin_password" {
  sensitive   = true
  description = "Admin password"
}

variable "controller_fqdn" {
  description = "FQDN or IP of the Aviatrix Controller"
  sensitive   = true
}

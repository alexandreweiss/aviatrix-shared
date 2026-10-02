variable "access_key" {
  description = "The access key to the Megaport API"
  sensitive   = true
}

variable "secret_key" {
  description = "The secret key of the MegaPort API"
  sensitive   = true
}

variable "azure_r1_location" {
  default     = "East US"
  description = "region to deploy resources"
  type        = string
}

variable "azure_r1_location_short" {
  default     = "eus"
  description = "region to deploy resources"
  type        = string
}

variable "private_peering_vlanid" {
  description = "Azure Express Route Private Peering VLAN ID"
  type        = string
  default     = 100
}

variable "er_peering_location" {
  description = "Azure Express Route Peering Location"
  type        = string
  default     = "New York"
}

variable "er_peering_location_short" {
  description = "Azure Express Route Location Short Name"
  type        = string
  default     = "ny"
}

variable "mp_location_short" {
  description = "Megaport Location Short Name"
  type        = string
  default     = "ny9"
}

variable "mp_mcr_asn" {
  description = "Megaport MCR ASN"
  type        = number
  # default     = 64003 # MCR2
  default = 64001
}

variable "ssh_public_key" {
  sensitive   = true
  description = "SSH public key for VM administration"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQBsUy8OllCkhpOU4FplN1b7ypawC/8QM++3gb9EbqZHCJnJdTNhk/0QZVvGsPvWeSazsShgX2TdEMMdDFscWDdAfnoB+hyjhFyWaOfKXFdzafib3HrO0rGUPqW42V6d0N2V5rh23ZFZGX5Bp75KEFnrFgGY1axCebvMvStGzXXffole1sCt0SKbvFptc/MT/ZVSqT0i0ugS0dVXsb4kuo4qnNRUAqvunljDL5oS3ZT7bQtjAvcw+IyYF6Ka9pGc4EuNaYZ2YuaxMyMOKYoMq4Qz8Qk5oF34ATGCPC0SdAgtAByNblbYeB6s+ueWUwSEcKOfIKjl9lxJasCRBRkjl7zp non-prod-test"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  # default     = "10.190.0.0/24" # MCR2
  default = "10.90.0.0/24"
}

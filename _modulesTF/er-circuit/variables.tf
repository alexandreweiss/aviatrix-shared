variable "resource_group_name" {
  description = "Resource group to create circuit in"
}

variable "location" {
  description = "Location to create circuit in"
}

variable "circuit_name" {
  description = "name of the circuit"
}

variable "peering_location" {
  description = "Peering Location of the circuit"
}

variable "circuit_bandwidth" {
  default     = 50
  description = "size of the circuit"
}

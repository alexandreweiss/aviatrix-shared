variable "cato_api_key" {
  description = "Cato API key"
  type        = string
  sensitive   = true
}

variable "cato_account_id" {
  description = "Cato account ID"
  type        = string
}

variable "admin_password" {
  description = "Aviatrix controller admin password"
  type        = string
  sensitive   = true
}

variable "controller_fqdn" {
  description = "FQDN or IP of the Aviatrix Controller"
  type        = string
  sensitive   = true
}

variable "cato_ipsec_psk" {
  description = "Pre shared key shared by all Cato <-> spoke tunnels"
  type        = string
  sensitive   = true
}

variable "cato_site_name" {
  description = "New Cato IPsec site for the MyApp2 spoke"
  type        = string
  default     = "azure-central-india-myapp2"
}

variable "cato_native_network_range" {
  description = "Cato site native range: the network behind the site (here the BGP spoke VNet CIDR)"
  type        = string
  default     = "10.10.6.0/23"
}

variable "cato_pop_ips" {
  description = "Public IPs of the two Cato PoPs (primary, secondary)"
  type        = list(string)
  default     = ["113.30.136.81", "113.30.136.22"]
}

variable "cato_asn" {
  type    = number
  default = 65111
}

variable "cato_transit_site_name" {
  description = "Existing Cato IPsec site holding the tunnels to the Aviatrix transit (imported, never changed)"
  type        = string
  default     = "azure-central-india"
}

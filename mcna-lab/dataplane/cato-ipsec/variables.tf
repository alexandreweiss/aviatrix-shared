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

variable "backup_prepend_as_path" {
  description = "AS path prepended on the backup (PoP 2) connection towards Cato"
  type        = list(string)
  default     = []
}

variable "metric_primary" {
  description = "Cato BGP peer metric for the primary PoP (lower is preferred)"
  type        = number
  default     = 100
}

variable "metric_backup" {
  description = "Cato BGP peer metric for the backup PoP (lower is preferred)"
  type        = number
  default     = 100
}

variable "active_pops" {
  description = "Cato PoPs the Aviatrix spoke connects to: primary (PoP 1) and/or secondary (PoP 2)"
  type        = list(string)
  default     = ["primary", "secondary"]
}

variable "transit_active_pops" {
  description = "Cato PoPs the transit connects to: primary (PoP 1) and/or secondary (PoP 2)"
  type        = list(string)
  default     = ["primary", "secondary"]
}

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

variable "peer_metric_overrides" {
  description = "Per Cato BGP peer metric override (50-255, lower preferred). Keys: primary-0 = spoke primary GW, primary-1 = spoke HA GW (PoP 1); secondary-0/1 for PoP 2. Asymmetry test: HA GW preferred for ingress."
  type        = map(number)
  default     = {}
}

variable "enable_dcf_stateful_test" {
  description = "Create the temporary DCF rules used to test statefulness with asymmetric paths"
  type        = bool
  default     = false
}

variable "enable_dcf_allweb_rule" {
  description = "Create the DCF rule that permits web (AllWeb web group) egress for the Gatus VMs, at the top of the policy list"
  type        = bool
  default     = false
}

variable "single_pop_transit" {
  description = "Test switch: connect the Aviatrix transit to Cato PoP 1 only (no backup peer, 2 tunnels) instead of the HA full mesh"
  type        = bool
  default     = false
}

variable "single_pop_spoke" {
  description = "Test switch: connect the MyApp2 spoke to Cato PoP 1 only (no backup peer, 2 tunnels) instead of the HA full mesh"
  type        = bool
  default     = false
}

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

variable "customer_name" {
  description = "Name of customer to be used in resources"
  default     = "contoso"
}

variable "otel_image_tag" {
  description = "OpenTelemetry Collector (core) image tag"
  type        = string
  default     = "0.164.0"
}

variable "otel_dns_label" {
  description = "DNS label -> <label>.<region>.azurecontainer.io. Must be unique per region. Defaults to a generated one."
  type        = string
  default     = null
}

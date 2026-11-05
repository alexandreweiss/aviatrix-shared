resource "azurerm_resource_group" "otel" {
  location = var.azure_r1_location
  name     = "azr-${var.azure_r1_location_short}-otel-${var.customer_name}-rg"
}

resource "random_string" "dns" {
  length  = 6
  upper   = false
  special = false
}

locals {
  dns_label = coalesce(var.otel_dns_label, "avx-otel-${random_string.dns.result}")
  # Known before the container group exists -> usable as cert SAN
  fqdn = "${local.dns_label}.${azurerm_resource_group.otel.location}.azurecontainer.io"
}

# Self-signed cert. Give tls_ca_certificate_pem to Aviatrix as "CA Certificate".
resource "tls_private_key" "otel" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "otel" {
  private_key_pem       = tls_private_key.otel.private_key_pem
  validity_period_hours = 8760
  is_ca_certificate     = true
  dns_names             = [local.fqdn]

  subject {
    common_name  = local.fqdn
    organization = "aviatrix-lab"
  }

  allowed_uses = ["key_encipherment", "digital_signature", "server_auth", "cert_signing"]
}

resource "azurerm_container_group" "otel" {
  name                = "otel-collector"
  location            = azurerm_resource_group.otel.location
  resource_group_name = azurerm_resource_group.otel.name
  os_type             = "Linux"
  restart_policy      = "Always"

  ip_address_type = "Public"
  dns_name_label  = local.dns_label

  exposed_port {
    port     = 4317 # OTLP gRPC
    protocol = "TCP"
  }

  exposed_port {
    port     = 4318 # OTLP HTTP
    protocol = "TCP"
  }

  container {
    name   = "otelcol"
    image  = "otel/opentelemetry-collector:${var.otel_image_tag}"
    cpu    = 1
    memory = 1

    commands = ["/otelcol", "--config=/etc/otelcol/config.yaml"]

    ports {
      port     = 4317
      protocol = "TCP"
    }

    ports {
      port     = 4318
      protocol = "TCP"
    }

    volume {
      name       = "config"
      mount_path = "/etc/otelcol"
      read_only  = true
      secret = {
        "config.yaml" = base64encode(file("${path.module}/otel-config.yaml"))
        "tls.crt"     = base64encode(tls_self_signed_cert.otel.cert_pem)
        "tls.key"     = base64encode(tls_private_key.otel.private_key_pem)
      }
    }
  }
}

output "fqdn" {
  value = azurerm_container_group.otel.fqdn
}

output "ip" {
  value = azurerm_container_group.otel.ip_address
}

# --- Aviatrix Telemetry Export Profile values ---

output "aviatrix_grpc_destination" {
  description = "Aviatrix profile: protocol 'gRPC with Server TLS' -> Destination Endpoint (host:port, no scheme)"
  value       = "${azurerm_container_group.otel.fqdn}:4317"
}

output "aviatrix_http_destination" {
  description = "Aviatrix profile: protocol 'HTTP with TLS' -> Destination Endpoint (full URL)"
  value       = "https://${azurerm_container_group.otel.fqdn}:4318"
}

output "aviatrix_ca_certificate_pem" {
  description = "Paste into Aviatrix 'CA Certificate' field (self-signed, so it is its own CA)"
  value       = tls_self_signed_cert.otel.cert_pem
}

output "logs_cmd" {
  value = "az container logs -g ${azurerm_resource_group.otel.name} -n ${azurerm_container_group.otel.name} --follow"
}

output "private_dns_resolver_inbound_endpoint_ip" {
  value       = azurerm_private_dns_resolver_inbound_endpoint.dns-inbound.ip_configurations[0].private_ip_address
  description = "The private IP address of the DNS resolver inbound endpoint."
}

output "cognitive_service_endpoint_url" {
  value       = azurerm_cognitive_account.aviatrix-ignite.endpoint
  description = "The endpoint URL of the Cognitive service."
}

output "openai_cognitive_service_deployment_name" {
  value       = azurerm_cognitive_deployment.aviatrix.name
  description = "The name of the OpenAI Cognitive service deployment."
}

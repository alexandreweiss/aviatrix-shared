# Output values for the Edge KVM deployment

output "public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.main.ip_address
}

output "cockpit_url" {
  description = "Cockpit web interface URL"
  value       = "https://${azurerm_public_ip.main.fqdn}:9090"
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "file_share_name" {
  description = "Name of the file share"
  value       = azurerm_storage_share.main.name
}


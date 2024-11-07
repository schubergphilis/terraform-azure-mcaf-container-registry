output "azure_container_registry_admin_username" {
  value = one(azurerm_container_registry.this.admin_username)
}

output "azure_container_registry_admin_password" {
  value = one(azurerm_container_registry.this.admin_password)
}

output "name" {
  description = "The name of the parent resource."
  value       = azurerm_container_registry.this.name
}

output "login_server" {
  description = "The login server of the parent resource."
  value       = azurerm_container_registry.this.login_server
}

output "resource" {
  description = "This is the full output for the resource."
  value       = azurerm_container_registry.this
}

output "resource_id" {
  description = "The resource id for the parent resource."
  value       = azurerm_container_registry.this.id
}

output "system_assigned_mi_principal_id" {
  description = "The system assigned managed identity principal ID of the parent resource."
  value       = one(azurerm_container_registry.this.identity[0].principal_id)
}
output "azure_container_registry_admin_username" {
  value = azurerm_container_registry.this.admin_username
}

output "azure_container_registry_admin_password" {
  value = azurerm_container_registry.this.admin_password
}

output "name" {
  description = "The name of the parent resource."
  value       = azurerm_container_registry.this.name
}

output "login_server" {
  description = "The login server of the parent resource."
  value       = azurerm_container_registry.this.login_server
}

# Module owners should include the full resource via a 'resource' output
# https://azure.github.io/Azure-Verified-Modules/specs/terraform/#id-tffr2---category-outputs---additional-terraform-outputs
output "resource" {
  description = "This is the full output for the resource."
  value       = azurerm_container_registry.this
}

# Minimum required outputs
# https://azure.github.io/Azure-Verified-Modules/specs/shared/#id-rmfr7---category-outputs---minimum-required-outputs
output "resource_id" {
  description = "The resource id for the parent resource."
  value       = azurerm_container_registry.this.id
}

output "system_assigned_mi_principal_id" {
  description = "The system assigned managed identity principal ID of the parent resource."
  value       = try(azurerm_container_registry.this.identity[0].principal_id, null)
}
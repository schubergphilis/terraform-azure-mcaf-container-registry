data "azurerm_key_vault_key" "this" {
  count = var.customer_managed_key == null ? 0 : 1

  key_vault_id = var.customer_managed_key.key_vault_resource_id
  name         = var.customer_managed_key.key_name
}

data "azurerm_user_assigned_identity" "this" {
  count = var.customer_managed_key == null ? 0 : (var.customer_managed_key.user_assigned_identity != null ? 1 : 0)

  name                = provider::azurerm::parse_resource_id(var.customer_managed_key.user_assigned_identity.resource_id)["resource_name"]
  resource_group_name = provider::azurerm::parse_resource_id(var.customer_managed_key.user_assigned_identity.resource_id)["resource_group_name"]
}
locals {
  acr_managed_identities = {
    system_assigned_user_assigned = (var.acr.managed_identities.system_assigned && (length(var.acr.managed_identities.user_assigned_resource_ids) > 0 || var.customer_managed_key.user_assigned_identity != null) ? {
      this = {
        type                       = "SystemAssigned, UserAssigned"
        user_assigned_resource_ids = distinct(flatten(var.acr.managed_identities.user_assigned_resource_ids, try([data.azurerm_user_assigned_identity.this[0].id],[]))
      }
    } : {}
    system_assigned = var.acr.managed_identities.system_assigned ? {
      this = {
        type = "SystemAssigned"
      }
    } : {}
    user_assigned = (length(var.acr.managed_identities.user_assigned_resource_ids) > 0 || var.customer_managed_key.user_assigned_identity != null) ? {
      this = {
        type                       = "UserAssigned"
        user_assigned_resource_ids = distinct(flatten(var.acr.managed_identities.user_assigned_resource_ids, try([data.azurerm_user_assigned_identity.this[0].id],[]))
      }
    } : {}
  }
  ordered_geo_replications = { for geo in var.acr.georeplications : geo.location => geo }
}
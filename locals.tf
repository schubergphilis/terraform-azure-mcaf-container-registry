locals {
  acr_managed_identities = {
    system_assigned_user_assigned = (var.acr.managed_identities.system_assigned || length(var.acr.managed_identities.user_assigned_resource_ids) > 0) ? {
      this = {
        type                       = var.acr.managed_identities.system_assigned && (length(var.acr.managed_identities.user_assigned_resource_ids) || var.customer_managed_key.user_assigned_identity != null) > 0 ? "SystemAssigned, UserAssigned" : length(var.acr.managed_identities.user_assigned_resource_ids) > 0 ? "UserAssigned" : "SystemAssigned"
        user_assigned_resource_ids = var.acr.managed_identities.user_assigned_resource_ids
      }
    } : {}
    system_assigned = var.acr.managed_identities.system_assigned ? {
      this = {
        type = "SystemAssigned"
      }
    } : {}
    user_assigned = length(var.acr.managed_identities.user_assigned_resource_ids) > 0 ? {
      this = {
        type                       = "UserAssigned"
        user_assigned_resource_ids = var.acr.managed_identities.user_assigned_resource_ids
      }
    } : {}
  }
  ordered_geo_replications = { for geo in var.acr.georeplications : geo.location => geo }
}
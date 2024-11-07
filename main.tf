resource "azurerm_resource_group" "this" {
  count = var.resource_group_name == null ? 0 : 1

  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_container_registry" "this" {
  name                          = var.acr.name
  location                      = var.acr.location == null ? azurerm_resource_group.this[0].location : var.acr.location
  resource_group_name           = var.acr.resource_group_name == null ? azurerm_resource_group.this[0].name : var.acr.resource_group_name
  sku                           = var.acr.sku
  admin_enabled                 = var.acr.admin_enabled
  anonymous_pull_enabled        = var.acr.anonymous_pull_enabled
  retention_policy_in_days      = var.acr.retention_policy_in_days
  export_policy_enabled         = var.acr.export_policy_enabled
  network_rule_bypass_option    = var.acr.network_rule_bypass_option
  public_network_access_enabled = var.acr.public_network_access_enabled
  quarantine_policy_enabled     = var.acr.quarantine_policy_enabled
  trust_policy_enabled          = var.acr.enable_trust_policy
  zone_redundancy_enabled       = var.acr.zone_redundancy_enabled

  dynamic "encryption" {
    for_each = var.customer_managed_key != null ? { this = var.customer_managed_key } : {}

    content {
      identity_client_id = data.azurerm_user_assigned_identity.this[0].client_id
      key_vault_key_id   = data.azurerm_key_vault_key.this[0].id
    }
  }

  dynamic "georeplications" {
    for_each = local.ordered_geo_replications

    content {
      location                  = georeplications.value.location
      regional_endpoint_enabled = georeplications.value.regional_endpoint_enabled
      tags                      = georeplications.value.tags
      zone_redundancy_enabled   = georeplications.value.zone_redundancy_enabled
    }
  }

  dynamic "identity" {
    for_each = local.acr_managed_identities.system_assigned_user_assigned

    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }

  # Only one network_rule_set block is allowed.
  # Create it if the variable is not null.
  dynamic "network_rule_set" {
    for_each = var.acr.network_rule_set != null ? { this = var.acr.network_rule_set } : {}

    content {
      default_action = network_rule_set.value.default_action

      dynamic "ip_rule" {
        for_each = network_rule_set.value.ip_rule

        content {
          action   = ip_rule.value.action
          ip_range = ip_rule.value.ip_range
        }
      }
    }
  }

  tags = merge(
    var.tags,
    tomap({
      "ResourceType" = "Container Registry"
    })
  )

  lifecycle {
    precondition {
      condition     = var.acr.zone_redundancy_enabled && var.acr.sku == "Premium" || !var.acr.zone_redundancy_enabled
      error_message = "The Premium SKU is required if zone redundancy is enabled."
    }
    precondition {
      condition     = var.acr.network_rule_set != null && var.acr.sku == "Premium" || var.acr.network_rule_set == null
      error_message = "The Premium SKU is required if a network rule set is defined."
    }
    precondition {
      condition     = var.customer_managed_key != null && var.acr.sku == "Premium" || var.customer_managed_key == null
      error_message = "The Premium SKU is required if a customer managed key is defined."
    }
    precondition {
      condition     = var.acr.quarantine_policy_enabled != null && var.acr.sku == "Premium" || var.acr.quarantine_policy_enabled == null
      error_message = "The Premium SKU is required if quarantine policy is enabled."
    }
    precondition {
      condition     = var.acr.retention_policy_in_days != null && var.acr.sku == "Premium" || var.acr.retention_policy_in_days == null
      error_message = "The Premium SKU is required if retention policy is defined."
    }
    precondition {
      condition     = var.acr.export_policy_enabled != null && var.acr.sku == "Premium" || var.acr.export_policy_enabled == null
      error_message = "The Premium SKU is required if export policy is enabled."
    }
  }
}

resource "azurerm_role_assignment" "acr" {
  for_each = var.acr.role_assignments != null ? var.acr.role_assignments : {}

  scope                = azurerm_container_registry.this.id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.id

  lifecycle {
    precondition {
      condition     = each.value.role_definition_name == "AcrPush" || each.value.role_definition_name == "AcrPull"
      error_message = "The role definition must be either 'AcrPull' or 'AcrPush'."
    }
    precondition {
      condition     = can(regex("^([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})$", each.value.id))
      error_message = "The principal ID must be a valid object ID or principal ID."
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                           = each.value.name != null ? each.value.name : "diag-${var.acr.name}"
  target_resource_id             = azurerm_container_registry.this.id
  eventhub_authorization_rule_id = each.value.event_hub_authorization_rule_resource_id
  eventhub_name                  = each.value.event_hub_name
  log_analytics_destination_type = each.value.log_analytics_destination_type
  log_analytics_workspace_id     = each.value.workspace_resource_id
  partner_solution_id            = each.value.marketplace_partner_resource_id
  storage_account_id             = each.value.storage_account_resource_id

  dynamic "enabled_log" {
    for_each = each.value.log_categories

    content {
      category = enabled_log.value
    }
  }
  dynamic "enabled_log" {
    for_each = each.value.log_groups

    content {
      category_group = enabled_log.value
    }
  }
  dynamic "metric" {
    for_each = each.value.metric_categories

    content {
      category = metric.value
    }
  }
}
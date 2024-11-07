run "basic" {
  variables {
    acr = {
      name                          = "myacr123"
      resource_group_name           = "myrg"
      location                      = "germanywestcentral"
      admin_enabled                 = false
      public_network_access_enabled = false
      network_rule_bypass_option    = "AzureServices"
    }
    tags = {
      "deploymentmodel" = "Terraform"
    }
  }

  module {
    source = "./"
  }

  command = plan

  assert {
    condition     = resource_exists("azurerm_container_registry.myacr")
    error_message = "Container Registry not created"
  }

  assert {
    condition     = resource_attribute_equals("azurerm_container_registry.myacr", "name", "myacr123")
    error_message = "Container Registry name mismatch"
  }

  assert {
    condition     = resource_attribute_equals("azurerm_container_registry.myacr", "location", "germanywestcentral")
    error_message = "Container Registry location mismatch"
  }

  assert {
    condition     = resource_attribute_equals("azurerm_container_registry.myacr", "admin_enabled", false)
    error_message = "Container Registry admin_enabled mismatch"
  }

  assert {
    condition     = resource_attribute_equals("azurerm_container_registry.myacr", "public_network_access_enabled", false)
    error_message = "Container Registry public_network_access_enabled mismatch"
  }

  assert {
    condition     = resource_attribute_equals("azurerm_container_registry.myacr", "network_rule_bypass_option", "AzureServices")
    error_message = "Container Registry network_rule_bypass_option mismatch"
  }
}
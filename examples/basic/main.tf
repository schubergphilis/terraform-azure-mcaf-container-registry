terraform {
  required_version = ">= 1.8"
}

module "acr" {
  source = "../.."

  acr = {
    name                = "myacr"
    resource_group_name = "myrg"
    location            = "germanywestcentral"
    sku                 = "Premium"
    admin_enabled       = false
    network_rule_set = {
      default_action = "Allow"
      ip_rule = [{
        action   = "Allow"
        ip_range = join(",", "1.2.3.4")
      }]
    }
  }
}

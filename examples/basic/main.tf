terraform {
  required_version = ">= 1.8"
}

module "acr" {
  source = "../.."

  acr = {
    name                = "myacr"
    resource_group_name = "myrg"
    location            = "germanywestcentral"
    admin_enabled       = false
    public_network_access_enabled = false
    network_rule_bypass_option    = "AzureServices"
  }
  tags = {
    "deploymentmodel" = "Terraform"
  }
}

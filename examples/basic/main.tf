terraform {
  required_version = ">= 1.8"

  backend "local" {
    path = "./terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4"
    }
  }
}

module "acr" {
  source = "../.."

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

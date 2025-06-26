terraform {
  required_version = ">=0.12"

  required_providers {

    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.26.0"

    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
  # skip_provider_registration = "true"
  subscription_id                 = "4f6a6eb9-27d0-4ed6-a31c-2bde135e2db6"
  resource_provider_registrations = "none"
}

terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id

  # Providers are already registered on this subscription; don't let Terraform
  # try to (re)register every RP — that races and 409s on a shared sub.
  resource_provider_registrations = "none"
}

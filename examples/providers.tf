#--------------------
# Required Providers
#--------------------
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.0.0"
    }
  }
  required_version = ">=0.13"
}

provider "azurerm" {
  features {}
  # subscription_id = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
  subscription_id = "ba143abd-03c0-43fc-bb1f-5bf74803b418"
}
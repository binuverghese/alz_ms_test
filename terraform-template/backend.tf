terraform {
  backend "azurerm" {
    resource_group_name   = "rg-dev-001"
    storage_account_name  = "tfstatedemonew"
    container_name        = "tfstate"
    key                   = "tfestate1.tfstate"
  }
}

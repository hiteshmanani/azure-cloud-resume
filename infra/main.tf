# 1. RESOURCE GROUP

resource "azurerm_resource_group" "main-rg" {
  name     = "rg-${var.application_name}-${var.environment}"
  location = var.primary_location
  tags = {
    environment = "prod"
    application = "crc"
    created_by  = "terraform"
  }
}

# 2. STORAGE ACCOUNT 
resource "azurerm_storage_account" "main-crc-sa" {
  name                     = "sa${var.application_name}${var.environment}001"
  resource_group_name      = azurerm_resource_group.main-rg.name
  location                 = azurerm_resource_group.main-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  tags = {
    environment = "prod"
    application = "crc"
    created_by  = "terraform"
  }
}

# 3. STATIC WEBSITE HOSTING ENABLED ON THE STORAGE ACCOUNT

resource "azurerm_storage_account_static_website" "main-crc-website" {
  storage_account_id = azurerm_storage_account.main-crc-sa.id
  error_404_document = "404.html"
  index_document     = "index.html"
}

#4 Assigning the current user the "Storage Blob Data Contributor" role 
# on the storage account to be able to upload files to the $web container 
# of the storage account using Azure CLI.

data "azurerm_client_config" "current" {
}

resource "azurerm_role_assignment" "current-user-role-asignment" {
  scope                = azurerm_storage_account.main-crc-sa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}
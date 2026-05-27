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

# 5. COSMOS DB TABLE API

resource "azurerm_cosmosdb_account" "main-crc-cosmosdb" {
  name                = "cosmos-${var.application_name}-${var.environment}-001"
  location            = var.cosmos_db_location
  resource_group_name = azurerm_resource_group.main-rg.name
  offer_type          = "Standard"
  capacity {
    total_throughput_limit = 4000
  }
  backup {
    type                = "Continuous"
    tier                = "Continuous7Days"
  }

  kind = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    failover_priority = 0
    location          = var.cosmos_db_location
    zone_redundant    = false
  }

  capabilities {
    name = "EnableTable"
  }
  capabilities {
    name = "EnableServerless"
  }

}

resource "azurerm_cosmosdb_table" "visitor-counter-table" {
  name                = var.cosmos_db_table
  resource_group_name = azurerm_resource_group.main-rg.name
  account_name        = azurerm_cosmosdb_account.main-crc-cosmosdb.name

}











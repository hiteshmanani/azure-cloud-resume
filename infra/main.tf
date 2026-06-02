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

#to test infra deployment github actions workflow changes and 
# validate that the infrastructure is being provisioned correctly in Azure,

resource "azurerm_resource_group" "test-rg" {
  name     = "rg-${var.application_name}-${var.environment}-infra-w/f-test"
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
    type = "Continuous"
    tier = "Continuous7Days"
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

  tags = {
    environment = "prod"
    application = "crc"
    created_by  = "terraform"
  }

}

# Creating a Cosmos DB Table for visitor counter
resource "azurerm_cosmosdb_table" "visitor-counter-table" {
  name                = var.cosmos_db_table
  resource_group_name = azurerm_resource_group.main-rg.name
  account_name        = azurerm_cosmosdb_account.main-crc-cosmosdb.name

}

# 6. AZURE FUNCTION APP HOSTING
# Function App deployment/runtime storage account.
# Flex Consumption needs a storage account and private blob container 
# where Azure stores deployment packages and host runtime files.

resource "azurerm_storage_account" "main-crc-funcapp-sa" {
  name                     = "safuncapp${var.application_name}${var.environment}001"
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

# Contaier for Function App runtime and deployment packages insuide the storage account above.
resource "azurerm_storage_container" "main-crc-funcapp-container" {
  name                  = "container-funcapp-${var.application_name}-${var.environment}"
  storage_account_id    = azurerm_storage_account.main-crc-funcapp-sa.id
  container_access_type = "private"

}


# Flex Consumption App Service plan.
# sku_name = "FC1" is the Flex Consumption SKU; memory is configured on the Function App resource below.

resource "azurerm_service_plan" "main-crc-funcapp-asp" {
  name                = "asp-${var.application_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main-rg.name
  location            = azurerm_resource_group.main-rg.location
  os_type             = "Linux"
  sku_name            = "FC1"

  tags = {
    environment = "prod"
    application = "crc"
    created_by  = "terraform"
  }
}


# Python Azure Function App on Flex Consumption.
# This creates the empty Azure host; deploying backend/function_app.py happens separately for now.

resource "azurerm_function_app_flex_consumption" "main-crc-funcapp" {
  name                = "func-${var.application_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main-rg.name
  location            = azurerm_resource_group.main-rg.location

  service_plan_id = azurerm_service_plan.main-crc-funcapp-asp.id

  # Flex deployment package storage.
  # Terraform/provider uses these properties to configure platform storage, including AzureWebJobsStorage.
  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${azurerm_storage_account.main-crc-funcapp-sa.primary_blob_endpoint}${azurerm_storage_container.main-crc-funcapp-container.name}"
  storage_authentication_type = "StorageAccountConnectionString"
  storage_access_key          = azurerm_storage_account.main-crc-funcapp-sa.primary_access_key

  runtime_name    = "python"
  runtime_version = "3.12"

  # Flex Consumption sizing.
  # 512 MB matches the small manual deployment size; Azure can scale out up to maximum_instance_count when needed.
  instance_memory_in_mb  = 512
  maximum_instance_count = 20


  site_config {
    cors {
      allowed_origins = [
        "http://localhost:1313",
        trimsuffix(azurerm_storage_account.main-crc-sa.primary_web_endpoint, "/")
      ]
    }
  }

  # Keep only non-secret settings here.
  # Add AZURE_TABLE_CONNECTION_STRING manually in Azure Portal/CLI for now so it is not stored in Git or Terraform state.
  app_settings = {
    #SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
    # AZURE_TABLE_CONNECTION_STRING = var.AZURE_TABLE_CONNECTION_STRING
  }

  lifecycle {
    ignore_changes = [
      app_settings
    ]
  }

  tags = {
    environment = "prod"
    application = "crc"
    created_by  = "terraform"
  }

}











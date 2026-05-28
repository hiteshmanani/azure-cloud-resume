variable "application_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "primary_location" {
  type = string
}

variable "cosmos_db_location" {
  type = string
}

variable "cosmos_db_table" {
  type = string
}


# # This variable is for the Azure Function App application setting 
# that stores the Cosmos DB connection string. 
# It is marked as sensitive to avoid showing the value in Terraform plan/apply output
# We are setting connection string value manually in Azure Portal/ Azure CLI 
# for now to avoid storing it in Git or Terraform state, 
# but this variable can be used in the future if you want to manage the 
# connection string value with Terraform.

# variable AZURE_TABLE_CONNECTION_STRING {
#   type = string
#   sensitive = true
# }



# Infrastructure

Terraform for this project lives in `infra/`. It defines the Azure infrastructure for the production Cloud Resume Challenge environment.

## What Terraform Manages

Terraform manages Azure resources including:

- Resource group.
- Azure Storage account for static website hosting.
- Static website configuration.
- Azure Storage custom domain mapping for `www.hiteshmanani.com`.
- Cosmos DB Table API account.
- `VisitorCounter` table.
- Storage account and blob container used by Azure Functions runtime/deployment packages.
- Linux Flex Consumption service plan.
- Python Azure Function App.
- Function App CORS settings.

Cloudflare is not managed by Terraform in this project. DNS, proxy/TLS, redirects, and cache behavior are configured manually in Cloudflare.

## Important Files

- `infra/main.tf` defines Azure resources.
- `infra/variables.tf` defines input variables.
- `infra/terraform.tfvars` contains non-secret project values.
- `infra/outputs.tf` exposes useful output values.
- `infra/versions.tf` pins provider/backend configuration.
- `infra/.terraform.lock.hcl` locks provider selections.

Do not commit local state, generated plans, or `.terraform/` directories.

## Remote State

Terraform state tracks real infrastructure. It can contain sensitive values and should be treated carefully.

This project uses the Terraform `azurerm` backend. The backend block is intentionally configured through backend values supplied at `terraform init` time.

Example placeholder command:

```bash
cd infra
terraform init \
  -backend-config="resource_group_name=<TF_STATE_RESOURCE_GROUP>" \
  -backend-config="storage_account_name=<TF_STATE_STORAGE_ACCOUNT>" \
  -backend-config="container_name=<TF_STATE_CONTAINER>" \
  -backend-config="key=<TF_STATE_KEY>"
```

Never commit:

- `.terraform/`
- `*.tfstate`
- `*.tfstate.backup`
- `*.tfplan`
- debug scripts containing environment-specific values

## Secrets And Terraform

Application secrets should not be placed directly into Terraform unless there is a deliberate secret-management design.

For this project, the Cosmos DB Table API connection string is stored in Azure Function App settings outside committed Terraform code. The Terraform code intentionally avoids committing the value of `AZURE_TABLE_CONNECTION_STRING`.

Terraform state can capture sensitive values if they are managed by Terraform, so treat state storage as sensitive even when the `.tf` files look safe.

## Common Commands

Format:

```bash
cd infra
terraform fmt
```

Initialize:

```bash
terraform init
```

Validate:

```bash
terraform validate
```

Plan:

```bash
terraform plan
```

Apply:

```bash
terraform apply
```

Review plans before applying. Infrastructure changes can create, update, or destroy Azure resources.

## Customizing Resource Names

Azure resource names are globally unique in some services, especially storage accounts and Cosmos DB accounts. Anyone reusing this repository must customize names such as:

```text
<RESOURCE_GROUP_NAME>
<STORAGE_ACCOUNT_NAME>
<FUNCTION_APP_NAME>
<COSMOS_ACCOUNT_NAME>
```

The current project uses Terraform-managed names such as `sacrcprod001` and `func-crc-prod`, but those should not be copied blindly into another Azure subscription.

## Custom Domain Mapping

The Terraform-managed static website storage account includes a custom domain mapping for:

```text
www.hiteshmanani.com
```

This matters because Azure Storage needs to recognize the incoming host header. Cloudflare can proxy traffic to Azure, but Azure Storage still needs the custom domain configured or it can reject the request.

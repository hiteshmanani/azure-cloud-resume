# Infrastructure

Terraform defines the Azure resources used by Azure Cloud Resume. The goal was to build a repeatable infrastructure. 

## Managed Azure Resources

Terraform manages:

- Resource groups.
- Azure Storage account for static website hosting.
- Static website configuration.
- Cosmos DB Table API account.
- `VisitorCounter` table.
- Storage account and container used by Azure Functions runtime/deployment packages.
- Linux Flex Consumption App service plan.
- Python Azure Function App.
- Function App CORS settings.

Cloudflare is managed outside Terraform in this project.

## Terraform Files

| Path | Purpose |
| --- | --- |
| `infra/main.tf` | Azure resource definitions |
| `infra/variables.tf` | Input variables |
| `infra/terraform.tfvars` | Non-secret project values |
| `infra/outputs.tf` | Terraform outputs |
| `infra/versions.tf` | Provider and backend configuration |
| `infra/.terraform.lock.hcl` | Locked provider selections |

## Remote State

Terraform uses the `azurerm` backend for remote state. The backend block is intentionally empty in `versions.tf`; backend values are supplied during `terraform init`.

The remote state backend must exist before the main infrastructure can be initialized. In practice, that means an Azure Storage account and blob container are prepared for the Terraform state file before running the project Terraform configuration.

Example initialization shape:

```bash
cd infra
terraform init \
  -backend-config="resource_group_name=<TF_STATE_RESOURCE_GROUP>" \
  -backend-config="storage_account_name=<TF_STATE_STORAGE_ACCOUNT>" \
  -backend-config="container_name=<TF_STATE_CONTAINER>" \
  -backend-config="key=<TF_STATE_KEY>"
```

## Secrets And State

The Cosmos DB Table API connection string is configured on the Function App, not committed into Terraform code.

Terraform state can still contain sensitive resource data. Treat access to the remote state backend as privileged access.

## Command Flow

Typical local review flow:

```bash
cd infra
terraform fmt
terraform init
terraform validate
terraform plan
```

Apply only after reviewing the plan:

```bash
terraform apply
```

The GitHub Actions infrastructure workflow runs the same core checks and applies the saved plan from the workflow.

## Naming And Reuse

Some Azure names must be globally unique, especially storage accounts and Cosmos DB accounts. Anyone reusing the project should change names such as:

```text
<RESOURCE_GROUP_NAME>
<STORAGE_ACCOUNT_NAME>
<FUNCTION_APP_NAME>
<COSMOS_ACCOUNT_NAME>
```

The current production names, such as `sacrcprod001` and `func-crc-prod`, document this deployment. They should not be copied directly into a separate Azure subscription.

## Operational Notes

- Review Terraform plans before merge because the CI workflow applies infrastructure changes on `main`.
- Keep application secrets in the service configuration layer, not in Terraform variables committed to the repository.
- Keep Cloudflare changes coordinated with Azure Storage custom-domain configuration, but document those steps in the domain and troubleshooting docs rather than this Terraform reference.

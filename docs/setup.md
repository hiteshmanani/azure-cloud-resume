# Setup

This page explains the tools and local setup needed to work with the project. It intentionally uses placeholders for values that are specific to an Azure subscription or Cloudflare account.

## Required Tools

Install these before working with the full project:

- Git
- VS Code
- Azure CLI
- Terraform
- Python 3.12 or compatible Azure Functions Python runtime
- Azure Functions Core Tools
- Node.js and npm
- Hugo extended
- Go, used by Hugo Modules for the Adritian theme

You also need:

- An Azure account and subscription.
- A domain name if you want a custom domain.
- A Cloudflare account if you want to match this project's DNS/proxy/TLS setup.

## Safe Login

For local Azure work, use interactive Azure CLI login:

```bash
az login
az account set --subscription "<AZURE_SUBSCRIPTION_ID>"
```

Do not commit subscription IDs, tenant IDs, client IDs, client secrets, connection strings, access keys, or tokens.

## Clone The Repository

```bash
git clone <REPOSITORY_URL>
cd personal_website
```

## Frontend Setup

```bash
cd frontend
npm ci
hugo server
```

Open:

```text
http://localhost:1313/
```

Hugo writes generated output to `frontend/public/` when you build the site. Do not edit or commit that folder.

## Backend Setup

```bash
cd backend
python -m venv .venv
pip install -r requirements.txt
func start --cors http://localhost:1313
```

Local API:

```text
http://localhost:7071/api/visitor-count
```

Create `backend/local.settings.json` locally if you need to run the Function against your own Cosmos DB Table API account.

Example shape:

```json
{
  "IsEncrypted": false,
  "Values": {
    "FUNCTIONS_WORKER_RUNTIME": "python",
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "AZURE_TABLE_CONNECTION_STRING": "<COSMOS_CONNECTION_STRING>"
  }
}
```

Do not commit `local.settings.json`.

## Terraform Setup

Terraform lives in `infra/`.

Before running Terraform, replace project-specific values with your own:

```text
<RESOURCE_GROUP_NAME>
<STORAGE_ACCOUNT_NAME>
<FUNCTION_APP_NAME>
<COSMOS_CONNECTION_STRING>
```

Remote state backend values are supplied during `terraform init`. Use placeholders in documentation and secure values locally or in GitHub repository variables:

```bash
cd infra
terraform fmt
terraform init \
  -backend-config="resource_group_name=<TF_STATE_RESOURCE_GROUP>" \
  -backend-config="storage_account_name=<TF_STATE_STORAGE_ACCOUNT>" \
  -backend-config="container_name=<TF_STATE_CONTAINER>" \
  -backend-config="key=<TF_STATE_KEY>"
terraform validate
terraform plan
```

Run `terraform apply` only when you have reviewed the plan and understand the Azure resources that will change.

## Cloudflare And Domain Setup

To match the production architecture, you need:

- A registered domain.
- Cloudflare as the authoritative DNS provider.
- A proxied `www` CNAME pointing to your Azure Storage static website endpoint.
- A root/apex redirect to `www`.
- Cloudflare SSL/TLS mode set appropriately for HTTPS to the Azure Storage origin.

If future automation is added, use a limited Cloudflare token such as `<CLOUDFLARE_API_TOKEN>` stored securely outside the repository.

## Secret Handling Checklist

Never commit:

- `backend/local.settings.json`
- Cosmos DB connection strings
- Azure storage keys
- Function keys
- Azure tenant IDs, subscription IDs, client secrets, or credentials
- Cloudflare API tokens
- Terraform state or plan files
- `.terraform/`
- `.venv/`
- `frontend/public/`
- `frontend/node_modules/`

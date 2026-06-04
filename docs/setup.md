# Setup

This page covers the local tools and environment assumptions needed to work with Azure Cloud Resume.

## Required Tools

- Git
- VS Code or another editor
- Azure CLI
- Terraform
- Python 3.12 or a compatible Azure Functions Python runtime
- Azure Functions Core Tools
- Node.js and npm
- Hugo extended
- Go for Hugo Modules

You also need an Azure subscription. A custom domain and Cloudflare account are required only if you want to reproduce the public domain setup.

## Azure Login

Use Azure CLI for local authentication:

```bash
az login
az account set --subscription "<AZURE_SUBSCRIPTION_ID>"
```

Confirm the active subscription before running Terraform or Azure CLI deployment commands:

```bash
az account show --output table
```

## Clone

```bash
git clone <REPOSITORY_URL>
cd azure-cloud-resume
```

## Frontend

```bash
cd frontend
npm ci
hugo server
```

Local site:

```text
http://localhost:1313/
```

Hugo generates `frontend/public/` only when the site is built. It is expected to be absent in a fresh clone.

## Backend

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

Local Function settings are stored in `backend/local.settings.json`. The file should contain local values only, including the Cosmos DB Table API connection string for the account you are testing against.

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

## Terraform Remote State Prerequisite

This project uses Terraform remote state with the AzureRM backend. The remote state storage account and blob container must exist before running `terraform init` for the main infrastructure.

At minimum, prepare:

```text
<TF_STATE_RESOURCE_GROUP>
<TF_STATE_STORAGE_ACCOUNT>
<TF_STATE_CONTAINER>
<TF_STATE_KEY>
```

The state backend is separate from the application infrastructure. This keeps Terraform state available across local runs and GitHub Actions workflow runs.

## Terraform

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

Apply only after reviewing the plan:

```bash
terraform apply
```

## Domain And Cloudflare

To reproduce the public domain setup, configure:

- Cloudflare as authoritative DNS provider, [example article shows to to set up DNS records for your domain in a Cloudflare account if your domain is from another registrar](https://www.namecheap.com/support/knowledgebase/article.aspx/9607/2210/how-to-set-up-dns-records-for-your-domain-in-a-cloudflare-account/)
- Proxied `www` CNAME to the Azure Storage static website endpoint.
- Proxied apex record so Cloudflare can redirect the root domain to `www`.
- Cloudflare HTTPS/TLS settings for browser-to-Cloudflare and Cloudflare-to-origin traffic.
- Azure Storage custom domain configuration for the public host.

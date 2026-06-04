# Troubleshooting

This guide covers the failure modes most likely to matter when operating or reusing the project.

## Azure Storage InvalidUri After Custom Domain Cutover

Context:

The project originally used manually created Azure resources. Cloudflare pointed the public domain to the original Azure Storage static website account. During the Terraform cutover, Cloudflare was updated to point to the Terraform-managed storage account instead.

The important detail is that Azure Storage validates the incoming host header. DNS can point to the new storage endpoint correctly, but the storage account also has to be configured to recognize the custom hostname.

Symptom:

```text
Azure Storage returns InvalidUri after DNS or Cloudflare cutover.
```

Likely cause:

```text
Cloudflare forwards Host: <your-custom-domain>
Target Azure Storage account does not recognize <your-custom-domain>
Azure Storage rejects the request
```

Fix:

- Confirm Cloudflare points to the intended Azure Storage static website endpoint.
- Confirm the target storage account has the custom domain configured.
- Confirm the custom domain configuration is on the new target account, not only on the old account.
- Re-run Terraform plan after adding the storage account `custom_domain` configuration and confirm it shows no unexpected changes.

## CORS Error From Browser

Symptom:

The visitor counter API works from a direct HTTP client, but the browser blocks the request.

Likely cause:

The Function App does not allow the frontend origin in CORS settings.

Fix:

- Confirm the frontend is calling the expected Function App endpoint.
- Add the exact production site origin to Function App CORS.
- Include `http://localhost:1313` for local Hugo development.

## Visitor Counter Not Incrementing

Symptom:

The site loads, but the counter stays at the fallback value or does not change.

Check:

- Browser network request to `/api/visitor-count`.
- Function App logs.
- Function App setting for `AZURE_TABLE_CONNECTION_STRING`.
- Cosmos DB Table API account and `VisitorCounter` table.
- Counter entity with `PartitionKey = site` and `RowKey = main`.

The backend creates the entity automatically if it is missing, so persistent failures usually point to configuration, connection, or permissions.

## Function App Deployment Failure

Check:

- `AZURE_FUNCTION_APP_NAME` and `AZURE_FUNCTION_APP_RESOURCE_GROUP` repository variables.
- Backend deployment identity permissions.
- Python runtime version.
- Azure Functions remote build logs.
- Files excluded by `backend/.funcignore`.

## Terraform Plan Wants Unexpected Changes

Check:

- Whether the resource was changed manually in Azure.
- Whether the remote state backend points to the expected key.
- Whether provider versions or variables changed.
- Whether lifecycle rules intentionally ignore or track the setting in question.

Review the plan before applying. Unexpected infrastructure changes should be understood before merge.

## GitHub Actions OIDC Login Failure

Check:

- Workflow permissions include `id-token: write`.
- The repository variable uses the correct app registration client ID.
- The Microsoft Entra ID federated credential matches the repository, branch, and workflow context.
- The Azure RBAC assignment grants the workflow identity the required scope.

## Hugo Build Failure

Check:

- Hugo extended version.
- Node.js and `npm ci`.
- Go setup for Hugo Modules.
- Markdown front matter in recently edited content.

Local build:

```bash
cd frontend
npm ci
hugo --minify
```

## Azure CLI Authentication Issues

```bash
az login
az account list --output table
az account set --subscription "<AZURE_SUBSCRIPTION_ID>"
```

If a storage upload fails despite subscription-level management access, check Azure Storage data-plane RBAC such as Storage Blob Data Contributor.

## Cloudflare Cache Showing Old Site

Check:

- Azure Storage `$web` contents.
- Cloudflare cache.
- Browser cache.
- The frontend deployment workflow run that last uploaded generated files.

Cloudflare cache purge automation is planned; until then, purge cache manually when needed.

# Troubleshooting

This guide collects practical failure modes from the project.

## Azure Storage InvalidUri After Custom Domain Cutover

Symptom:

```text
Azure Storage returns InvalidUri after Cloudflare DNS is changed.
```

Likely cause:

Cloudflare is sending requests with `Host: www.hiteshmanani.com`, but the target Azure Storage account does not recognize that custom domain.

Fix:

- Confirm Cloudflare points to the intended Azure Storage static website endpoint.
- Confirm the Azure Storage account has the custom domain configured.
- If minimizing downtime, consider the Azure Storage `asverify` validation approach before cutover.

## CORS Error From Browser

Symptom:

The visitor counter API works with `curl`, but the browser blocks the request.

Likely cause:

The Function App CORS settings do not allow the website origin.

Fix:

- Add the exact frontend origin to Function App CORS settings.
- Include local development origin if testing with Hugo locally: `http://localhost:1313`.
- Confirm the frontend is calling the expected API URL.

## Visitor Counter Not Incrementing

Symptom:

The site loads but the counter stays at `--` or does not change.

Check:

- Browser network tab for the API request.
- Function App logs.
- `AZURE_TABLE_CONNECTION_STRING` in Function App settings.
- Cosmos DB Table API account and `VisitorCounter` table.
- Entity with `PartitionKey = site` and `RowKey = main`.

The backend creates the entity automatically if it is missing, so repeated failures usually point to configuration, connection, or permission issues.

## Function App Deployment Failure

Symptom:

GitHub Actions fails during backend deployment.

Check:

- `AZURE_FUNCTION_APP_NAME` repository variable.
- `AZURE_FUNCTION_APP_RESOURCE_GROUP` repository variable.
- Backend deployment identity permissions.
- Python runtime version.
- `backend/.funcignore` exclusions.
- Remote build logs in the workflow output.

## Terraform Plan Wants Unexpected Changes

Symptom:

`terraform plan` shows changes you did not expect.

Check:

- Whether someone changed the resource manually in Azure Portal.
- Whether provider versions changed.
- Whether `terraform.tfvars` changed.
- Whether remote state points to the expected backend key.
- Whether lifecycle `ignore_changes` is intentionally hiding or allowing a setting.

Do not apply an unexpected plan until you understand the diff.

## GitHub Actions OIDC Login Failure

Symptom:

Azure login fails in a workflow without a client secret.

Check:

- Correct GitHub repository variables for tenant, subscription, and client ID.
- Federated credential issuer, subject, and audience in Azure.
- Workflow permissions include `id-token: write`.
- The workflow is running from the branch/environment expected by the federated credential.

## Hugo Build Failure

Symptom:

Frontend workflow fails before deployment.

Check:

- Hugo extended version.
- Node.js version and `npm ci`.
- Go setup for Hugo Modules.
- Theme module resolution.
- Recent content changes with invalid front matter.

Run locally:

```bash
cd frontend
npm ci
hugo --minify
```

## Azure CLI Authentication Issues

Symptom:

Local Azure CLI commands fail or target the wrong subscription.

Fix:

```bash
az login
az account list --output table
az account set --subscription "<AZURE_SUBSCRIPTION_ID>"
```

If a storage upload fails even though you are subscription Owner, check data-plane permissions such as Storage Blob Data Contributor.

## Cloudflare Cache Showing Old Site

Symptom:

Azure Storage has new files, but the public site still shows old content.

Fix:

- Purge Cloudflare cache manually.
- Test the Azure Storage static website endpoint directly.
- Confirm the GitHub Actions frontend workflow uploaded the latest `frontend/public/` contents.
- Confirm the browser is not showing a local cached copy.

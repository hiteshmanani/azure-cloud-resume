# Security

This project is public-facing, so the documentation and repository are written with secret handling in mind.

## No Secrets In GitHub

Do not commit:

- Cosmos DB connection strings.
- Azure storage keys.
- Function keys.
- Azure client secrets.
- Azure tenant IDs or subscription IDs.
- Cloudflare API tokens.
- GitHub tokens.
- `backend/local.settings.json`.
- Terraform state or plan files.

Use placeholders in docs:

```text
<AZURE_SUBSCRIPTION_ID>
<RESOURCE_GROUP_NAME>
<STORAGE_ACCOUNT_NAME>
<FUNCTION_APP_NAME>
<COSMOS_CONNECTION_STRING>
<CLOUDFLARE_API_TOKEN>
```

## OIDC Instead Of Client Secrets

GitHub Actions authenticates to Azure with OIDC/federated credentials. This lets GitHub request short-lived Azure tokens during workflow runs.

The benefit is simple: the repository does not need long-lived Azure client secrets for CI/CD.

## Separate Deployment Identities

The workflows use separate Azure app registrations/identities for different responsibilities:

- Frontend deployment identity for Azure Storage upload.
- Backend deployment identity for Azure Functions deployment.
- Infrastructure identity for Terraform.

This separation makes least privilege easier to reason about. Terraform usually needs broader permissions than a static-site upload workflow, so it should not share the same identity if avoidable.

## CORS Restrictions

The Function App allows expected origins such as:

- Local Hugo development at `http://localhost:1313`.
- The Azure Storage static website endpoint.
- `https://www.hiteshmanani.com`.
- `https://hiteshmanani.com`.

CORS does not replace authentication or secret management, but it helps ensure browser calls come from expected origins.

## Static Website Public Access

Azure Storage Static Website is intentionally public for generated website files. That public access is for static content only.

Secrets and source-only files should not be uploaded to `$web`. The deployment process should upload Hugo-generated output from `frontend/public/`, not repository internals or local settings.

## Cosmos DB Connection String Handling

The Cosmos DB Table API connection string is used by the Azure Function backend. It must stay server-side.

Appropriate locations:

- Local `backend/local.settings.json` during development.
- Azure Function App application settings in production.
- A secure secret store if the project later adopts one.

Inappropriate locations:

- Frontend JavaScript.
- Markdown docs.
- Terraform files committed to Git.
- GitHub Actions YAML.

## Terraform State Sensitivity

Terraform state can contain resource details and sensitive values. Even when secrets are not written directly into `.tf` files, state should still be treated as sensitive.

Do not commit:

```text
.terraform/
*.tfstate
*.tfstate.backup
*.tfplan
```

## Cloudflare Token Warning

Cloudflare is manually managed today. No Cloudflare API token is required for the current deployment flow.

If future cache purge automation is added, create a limited-scope Cloudflare API token and store it securely as a GitHub secret. Do not commit or print the token.

## Public Documentation Review Checklist

Before publishing, check that docs do not include:

- Real tenant IDs.
- Real subscription IDs.
- Client IDs if you prefer to keep them private.
- Connection strings.
- Storage keys.
- Function keys.
- Cloudflare tokens.
- Screenshots that reveal secrets or account identifiers.

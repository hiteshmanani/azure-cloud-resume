# Security

Azure Cloud Resume is public-facing, so the security model focuses on clear boundaries: static files are public, database access is server-side, deployment identities are scoped, and infrastructure state is treated as sensitive.

## Application Boundary

The browser downloads static files from Azure Storage and calls the visitor counter API. It does not receive Cosmos DB credentials and does not connect directly to the database.

The Azure Function owns the database operation:

```text
Browser
-> Azure Function HTTP API
-> Cosmos DB Table API
```

This keeps the counter implementation simple while preserving a server-side control point for the database connection string.

## Secret Handling

Sensitive values are kept out of source control:

- Cosmos DB Table API connection string.
- Azure storage keys.
- Function keys.
- Azure client secrets.
- Cloudflare API tokens.
- GitHub tokens.
- Terraform state and plan files.
- Local Function settings.

The Cosmos DB Table API connection string is configured as an Azure Function App application setting in production. Local development uses `backend/local.settings.json`.

## CI/CD Authentication

GitHub Actions authenticates to Azure with OIDC and Microsoft Entra ID federated credentials. The workflows do not need long-lived Azure client secrets.

The deployment model uses separate Azure identities for:

- Frontend deployment to Azure Storage.
- Backend deployment to Azure Functions.
- Infrastructure deployment with Terraform.

This separation keeps permissions easier to review and limits the blast radius of each workflow identity.

## CORS

The Function App CORS configuration allows the expected local and production origins. CORS is not the main security boundary, but it helps keep browser access scoped to the intended site origins.

## Static Website Hosting

Azure Storage Static Website is intentionally public for generated site files. The deployment workflow uploads Hugo build output, not repository internals or local configuration.

## Terraform State

Terraform state can contain sensitive resource data even when secrets are not written directly into `.tf` files. Access to the remote state backend should be limited to identities that need infrastructure visibility or deployment permissions.

## Cloudflare Token Scope

Cloudflare is manually managed in the current deployment flow. Cache purge automation is planned, and when it is added it should use a narrowly scoped Cloudflare token stored outside the repository.

# TODO

## Current Phase

Phase 5 - Testing and Terraform Infrastructure as Code.

The live site and visitor counter are working end to end:

```text
Browser
-> Cloudflare
-> Azure Storage Static Website
-> Hugo/JavaScript
-> Azure Function HTTP API
-> Python backend
-> Cosmos DB Table API
```

## Priority Tasks

1. Add backend tests for the visitor counter API.
   - Separate the counter read/increment/update behavior into testable logic if needed.
   - Mock Cosmos DB/Table client calls rather than using the live database in unit tests.
   - Cover successful increment, missing/invalid count values, and API response shape.

2. Start Terraform planning in `infra/`.
   - Use Terraform v1.15.3.
   - Build a fresh Terraform-managed Azure environment from scratch.
   - Do not import or adopt the current live resources.
   - Keep existing production untouched during Terraform development.
   - Manage Azure resources only.

3. Define the fresh Terraform environment.
   - Resource group.
   - Storage account with static website enabled.
   - Function App and required hosting resources.
   - Cosmos DB Table API account/table/entity setup where appropriate.
   - App settings for the Function App, with secret values supplied securely and not committed.

4. Keep Cloudflare manual for now.
   - Do not add the Cloudflare Terraform provider.
   - Do not request or use Cloudflare API tokens.
   - Later, manually repoint Cloudflare to the Terraform-created Azure Storage static website origin after it is tested.
   - Keep Cloudflare cache purge manual for now.

5. Plan CI/CD after Terraform design is stable.
   - Frontend build and upload to Azure Storage.
   - Backend deploy to Azure Functions.
   - Secure handling of Azure credentials and app settings.
   - No generated output or secrets committed.

6. Create final explanation artifacts.
   - Architecture diagram.
   - Cloud Resume Challenge case study page or blog post.
   - Interview-ready explanation of static hosting, serverless API, database, IaC, and CI/CD.

## Completed Milestones

- Personalized Hugo + Adritian portfolio site.
- Configured custom domain, HTTPS, Cloudflare proxy/CDN, and root-to-www redirect.
- Hosted generated Hugo site on Azure Storage Static Website.
- Added JavaScript visitor counter display in the footer.
- Created Azure Functions Python HTTP API.
- Connected Python backend to Cosmos DB Table API.
- Stored visitor count in table `VisitorCounter`, entity `PartitionKey = site`, `RowKey = main`.
- Deployed Function App `func-hm-crc`.
- Configured CORS for local Hugo and the live website.
- Updated frontend JavaScript to call local API during local development and deployed API in production.
- Confirmed live end-to-end visitor counter flow works.

## Current Live Resources

- Domain: `https://www.hiteshmanani.com`
- Storage account: `personalwebsitesacrc`
- Static website endpoint: `https://personalwebsitesacrc.z1.web.core.windows.net/`
- Function App: `func-hm-crc`
- API endpoint: `https://func-hm-crc-eaene9aufsf4cmen.uaenorth-01.azurewebsites.net/api/visitor-count`
- Resource group: `crc-personal-website`
- Region: `UAE North`
- Cosmos DB Table API account: `hm-crc-cosmosdb`
- Cosmos table: `VisitorCounter`

## Ongoing Rules

- Do not edit theme module internals unless necessary.
- Prefer local project overrides under `frontend/layouts/`.
- Do not commit or push from Codex.
- Do not commit generated or dependency folders:
  - `frontend/node_modules/`
  - `frontend/public/`
  - `frontend/resources/_gen/`
  - `frontend/.hugo_build.lock`
  - `.venv/`
  - `__pycache__/`
- Do not commit secrets, keys, tokens, connection strings, credentials, subscription IDs, or local settings.
- `backend/local.settings.json` must stay uncommitted.
- Frontend JavaScript must never talk directly to Cosmos DB.

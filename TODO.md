# TODO

## Current Phase

Phase 5 - Terraform/IaC has been validated end to end in a fresh Azure environment. The next planned phase is GitHub Actions CI/CD.

The original public production site remains behind Cloudflare:

```text
Browser
-> Cloudflare
-> Azure Storage Static Website
-> Hugo/JavaScript
-> Azure Function HTTP API
-> Python backend
-> Cosmos DB Table API
```

The fresh Terraform-managed environment is also working:

```text
Browser
-> Azure Storage Static Website at https://sacrcprod001.z1.web.core.windows.net/
-> Hugo/JavaScript
-> Azure Function App func-crc-prod
-> Python backend
-> Cosmos DB Table API
```

## Priority Tasks

1. Review and clean up Terraform code.
   - Confirm naming is consistent and beginner-readable.
   - Refine outputs for static website endpoint, Function App URL, and key non-secret resource names.
   - Keep secrets out of Terraform files and Terraform state where possible.
   - Preserve manual handling of `AZURE_TABLE_CONNECTION_STRING` for now, or replace with a deliberate secure secret-store plan later.

2. Add backend tests for the visitor counter API.
   - Mock Cosmos DB/Table client calls rather than using the live database.
   - Cover successful increment.
   - Cover automatic creation of the missing `PartitionKey = site`, `RowKey = main` entity.
   - Cover missing/invalid count values if behavior is added.
   - Cover API response shape.

3. Design GitHub Actions CI/CD.
   - Use `notes/ci-cd-plan.md` as the starting plan.
   - Do not add workflow YAML until the design is reviewed.
   - Prefer Azure OIDC/federated credentials instead of long-lived Azure secrets.
   - Keep frontend, backend, and Terraform workflows separate.

4. Keep Cloudflare manual for now.
   - Do not add the Cloudflare Terraform provider.
   - Do not request or use Cloudflare API tokens.
   - Do not automate Cloudflare purge yet.
   - Cut over Cloudflare only after Terraform-managed frontend and backend CI/CD are proven.

5. Create final explanation artifacts.
   - Architecture diagram.
   - Cloud Resume Challenge case study page or blog post.
   - Interview-ready explanation of static hosting, serverless API, database, IaC, CI/CD, and Cloudflare tradeoffs.

## Completed Milestones

- Personalized Hugo + Adritian portfolio site.
- Configured custom domain, HTTPS, Cloudflare proxy/CDN, and root-to-www redirect.
- Hosted generated Hugo site on Azure Storage Static Website.
- Added JavaScript visitor counter display in the footer.
- Created Azure Functions Python HTTP API.
- Connected Python backend to Cosmos DB Table API.
- Stored visitor count in table `VisitorCounter`, entity `PartitionKey = site`, `RowKey = main`.
- Deployed original/manual Function App `func-hm-crc`.
- Configured CORS for local Hugo and the live website.
- Confirmed original live end-to-end visitor counter flow works.
- Chose Terraform for IaC.
- Chose Option B: build a fresh Terraform-managed Azure environment from scratch.
- Provisioned Terraform resource group `rg-crc-prod`.
- Provisioned Terraform static website storage account `sacrcprod001`.
- Enabled static website hosting at `https://sacrcprod001.z1.web.core.windows.net/`.
- Uploaded Hugo build output to the Terraform storage account `$web` container.
- Provisioned Terraform Cosmos DB Table API account `cosmos-crc-prod-001` and table `VisitorCounter`.
- Updated Python backend to create the `site/main` counter entity automatically when missing.
- Provisioned Terraform Function App `func-crc-prod` on Flex Consumption.
- Set `AZURE_TABLE_CONNECTION_STRING` manually in Azure Function App settings.
- Updated frontend JavaScript to call the new Function App API.
- Confirmed Terraform-created frontend, Function App, and Cosmos DB work end to end.
- Added `notes/ci-cd-plan.md` for the next GitHub Actions phase.

## Current Manual Production Resources

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
  - `.python_packages/`
  - `__pycache__/`
- Do not commit secrets, keys, tokens, connection strings, credentials, subscription IDs, tenant IDs, or local settings.
- `backend/local.settings.json` must stay uncommitted.
- Frontend JavaScript must never talk directly to Cosmos DB.

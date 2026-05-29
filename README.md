# Azure Cloud Resume Challenge - Personal Website

This repository contains Hitesh Manani's Hugo + Adritian personal website and Azure Cloud Resume Challenge project.

The project is both a public personal portfolio and a hands-on cloud engineering build. It demonstrates static website hosting, a JavaScript visitor counter, an API layer, serverless Python backend code, database-backed state, Terraform infrastructure as code, and the upcoming GitHub Actions CI/CD phase.

Live public site:

```text
https://www.hiteshmanani.com
```

Current Terraform test site:

```text
https://sacrcprod001.z1.web.core.windows.net/
```

Cloudflare has not been repointed to the Terraform-managed environment yet.

## Current Status

Current phase: Phase 5 - Terraform/IaC completed enough for end-to-end validation; next phase is CI/CD planning and implementation.

There are two environments documented in this repository:

- Original manual production environment behind Cloudflare and the public domain.
- Fresh Terraform-managed Azure environment built from scratch without importing the original resources.

Original/manual production flow:

```text
Browser
-> Cloudflare
-> Azure Storage Static Website
-> Hugo/JavaScript
-> Azure Function HTTP API
-> Python backend
-> Cosmos DB Table API
```

Terraform-managed test flow:

```text
Browser
-> Azure Storage Static Website at https://sacrcprod001.z1.web.core.windows.net/
-> Hugo/JavaScript
-> Azure Function App func-crc-prod
-> Python backend
-> Cosmos DB Table API
```

The Terraform environment has been tested end to end. The frontend calls the Terraform-created Function App API, and the backend updates the Terraform-created Cosmos DB Table API visitor counter.

## Repository Structure

```text
frontend/   Hugo static site source and Adritian theme customizations
backend/    Azure Functions Python API for the visitor counter
infra/      Terraform Azure infrastructure
notes/      Handoff, setup, Cloudflare, content, and planning notes
```

Important handoff docs:

- `notes/project-handoff.md` is the main senior-engineer handover.
- `notes/ci-cd-plan.md` documents the next GitHub Actions phase.
- `WORKING_NOTES.md` tracks current project state.
- `TODO.md` tracks the current backlog.
- `notes/static-hosting-domain-cloudflare.md` documents the current manual Cloudflare/public-domain setup.

## Frontend

Frontend stack:

- Hugo static site generator
- Adritian Hugo theme
- Hugo Modules
- Project-level layout/style overrides
- JavaScript visitor counter

Important files:

- `frontend/hugo.toml` controls Hugo config, menus, modules, plugins, output, SEO, and site parameters.
- `frontend/content/` contains site content.
- `frontend/layouts/partials/footer.html` renders the visitor counter in the footer.
- `frontend/static/js/visitor-count.js` chooses the API URL:
  - local: `http://localhost:7071/api/visitor-count`
  - deployed: `https://func-crc-prod.azurewebsites.net/api/visitor-count`

Manual frontend deployment model:

```text
Hugo source
-> hugo build
-> frontend/public/
-> upload contents of public/ to Azure Storage $web container
```

Azure Storage hosts static output only. It does not host Hugo itself.

## Backend

Backend stack:

- Azure Functions Python v2 programming model
- Anonymous HTTP trigger at `GET /api/visitor-count`
- `azure-functions`
- `azure-data-tables`
- Cosmos DB Table API

The backend reads `AZURE_TABLE_CONNECTION_STRING` from the Function App environment, connects to the `VisitorCounter` table, and updates the entity:

```text
PartitionKey = site
RowKey       = main
Count        = incrementing integer
```

If the entity does not exist, the Python function creates it automatically with `Count = 1`.

## Terraform/IaC

Terraform direction:

- Terraform manages Azure infrastructure only.
- Terraform creates a fresh Azure environment from scratch.
- Existing manual production resources were not imported.
- Cloudflare remains manual for now.
- No Cloudflare provider or Cloudflare API token should be added unless this decision changes explicitly.

Known Terraform-managed resources documented in repo/code:

- Resource group: `rg-crc-prod`
- Static website storage account: `sacrcprod001`
- Static website endpoint: `https://sacrcprod001.z1.web.core.windows.net/`
- Function App: `func-crc-prod`
- Function hosting plan: Flex Consumption
- Cosmos DB Table API account: `cosmos-crc-prod-001`
- Cosmos table: `VisitorCounter`

Remote state is configured with Terraform's `azurerm` backend. Local backend values are supplied by `infra/.debug-prod.sh`, which is intentionally ignored because it contains environment-specific values.

## Original Manual Production Resources

These resources represent the existing public production environment documented before the Terraform rebuild:

- Canonical domain: `https://www.hiteshmanani.com`
- DNS/CDN/TLS/proxy: Cloudflare
- Azure Storage account: `personalwebsitesacrc`
- Static website endpoint: `https://personalwebsitesacrc.z1.web.core.windows.net/`
- Azure Function App: `func-hm-crc`
- API endpoint: `https://func-hm-crc-eaene9aufsf4cmen.uaenorth-01.azurewebsites.net/api/visitor-count`
- Resource group: `crc-personal-website`
- Region: `UAE North`
- Cosmos DB Table API account: `hm-crc-cosmosdb`
- Cosmos table: `VisitorCounter`

Do not treat these as Terraform-managed resources.

## Security Guardrails

Never commit:

- Azure secrets, credentials, subscription IDs, or tenant IDs
- Cosmos DB connection strings
- Function keys
- Storage account keys
- Cloudflare tokens
- GitHub tokens
- `backend/local.settings.json`
- `.terraform/`
- `*.tfstate`
- `*.tfstate.backup`
- `*.tfplan`
- `.venv/`
- `.python_packages/`
- `__pycache__/`
- debug scripts containing environment-specific values
- generated Hugo output such as `frontend/public/`

`AZURE_TABLE_CONNECTION_STRING` belongs in local settings for local development, or Azure Function App settings / secure secret stores for deployed environments. It must not be committed.

Frontend JavaScript must never talk directly to Cosmos DB. Browser traffic must go through the Azure Function API.

## Next Phase

The next planned phase is GitHub Actions CI/CD. Do not add workflow YAML until the workflow design is reviewed.

Planned workflow groups:

- Frontend CI/CD: build Hugo and deploy `frontend/public/` to the Terraform-managed Storage `$web` container.
- Backend CI/CD: install Python dependencies, run tests, deploy the Azure Functions app, and smoke test the API.
- Terraform CI: run `terraform fmt -check`, `terraform init`, `terraform validate`, and `terraform plan`; do not automate `terraform apply` yet.

See `notes/ci-cd-plan.md` for the beginner-friendly CI/CD plan.

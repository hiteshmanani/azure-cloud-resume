# Working Notes

## Project Goal

This repo is Hitesh Manani's Hugo + Adritian personal website for the Azure Cloud Resume Challenge.

The visible site is a polished personal portfolio and a credible Cloud Resume Challenge project. It positions Hitesh around Azure cloud engineering, AI platform delivery, customer-facing implementation, product assurance, stakeholder communication, enterprise rollout, and solutions/customer success engineering roles.

## Current Status

Current phase: Phase 5 - Testing and Terraform Infrastructure as Code.

The live project is working end to end:

```text
Browser
-> Cloudflare
-> Azure Storage Static Website
-> Hugo/JavaScript
-> Azure Function HTTP API
-> Python backend
-> Cosmos DB Table API
```

Live site:

```text
https://www.hiteshmanani.com
```

Visitor counter API:

```text
https://func-hm-crc-eaene9aufsf4cmen.uaenorth-01.azurewebsites.net/api/visitor-count
```

## Current Live Resources

- DNS/CDN/TLS/proxy: Cloudflare
- Azure Storage account: `personalwebsitesacrc`
- Static website endpoint: `https://personalwebsitesacrc.z1.web.core.windows.net/`
- Function App: `func-hm-crc`
- Resource group: `crc-personal-website`
- Region: `UAE North`
- Cosmos DB Table API account: `hm-crc-cosmosdb`
- Cosmos table: `VisitorCounter`
- Counter entity: `PartitionKey = site`, `RowKey = main`, `Count = incrementing`

## Codebase Shape

- `frontend/` contains the Hugo static site source. Hugo builds static output into `frontend/public/`.
- `frontend/static/js/visitor-count.js` calls the local API during local development and the deployed Azure Function API in production.
- `frontend/layouts/partials/footer.html` is a project-level footer override that displays the visitor count.
- `frontend/assets/css/custom.css` contains local visual overrides, including footer counter styling.
- `backend/` contains the Azure Functions Python API.
- `backend/function_app.py` defines the `GET /api/visitor-count` endpoint and increments the Cosmos DB Table count.
- `backend/requirements.txt` includes `azure-functions` and `azure-data-tables`.
- `backend/local.settings.json` is local-only and ignored by Git.
- `infra/` is the Terraform work area for the next phase.
- `notes/` contains project notes, handoffs, and troubleshooting material.

## Local Development

Frontend:

```bash
cd ~/Desktop/DEV/personal_website/frontend
hugo server
```

Open:

```text
http://localhost:1313/
```

Backend:

```bash
cd ~/Desktop/DEV/personal_website/backend
source .venv/Scripts/activate
func start --cors http://localhost:1313
```

Local API:

```text
http://localhost:7071/api/visitor-count
```

Known Python note:

- `py --version` works and points to Python 3.12.
- `python --version` may not work because Python is not directly on PATH.
- Use the virtual environment or `py` commands unless PATH is fixed.

## Completed Work

- Personalized Hugo + Adritian portfolio site.
- Configured Azure Storage Static Website hosting.
- Configured Cloudflare DNS/CDN/TLS/proxy and root-to-www redirect.
- Deployed site at `https://www.hiteshmanani.com`.
- Added JavaScript visitor counter display.
- Created Azure Functions Python backend.
- Connected backend to Cosmos DB Table API.
- Deployed Function App `func-hm-crc`.
- Configured CORS for local Hugo and the live website.
- Confirmed the live visitor counter increments Cosmos DB and displays on the site.

## Terraform Decision

Hitesh chose Terraform for Infrastructure as Code.

Current decision:

- Terraform installed locally: `v1.15.3`.
- Build a fresh Terraform-managed Azure environment from scratch.
- Do not import/adopt the existing live resources.
- Do not use Terraform import for now.
- Existing production stays untouched.
- Terraform manages Azure infrastructure only.

## Cloudflare Decision

Cloudflare remains manually managed for now.

- Do not add the Cloudflare Terraform provider.
- Do not request or use Cloudflare API tokens.
- Later, once the Terraform-created Azure Storage static website is tested, Cloudflare can be manually repointed to the new Azure Storage origin.
- Cloudflare cache purge remains manual.
- Future automated purge would require a limited Cloudflare API token stored securely in GitHub Actions secrets.

## Security Guardrails

Never commit:

- `backend/local.settings.json`
- `.venv/`
- `__pycache__/`
- Azure secrets
- Cosmos DB connection strings
- Function keys
- Storage account keys
- Cloudflare tokens
- GitHub tokens
- Azure credentials or subscription IDs

`AZURE_TABLE_CONNECTION_STRING` exists in local settings and Azure Function App settings only. Do not document or commit its value.

Frontend JavaScript must never talk directly to Cosmos DB. Browser traffic must call the Azure Function API only.

## Next Tasks In Priority Order

1. Add backend tests for visitor counter logic.
2. Design Terraform for a fresh Azure environment in `infra/`.
3. Keep current production resources untouched while Terraform is developed and tested.
4. Plan CI/CD for frontend and backend deployment after Terraform is stable.
5. Create an architecture diagram.
6. Write the Cloud Resume Challenge case study/blog post.

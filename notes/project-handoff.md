# Project Handoff

## Purpose

This file gives Codex or another engineer the current technical state of Hitesh Manani's Azure Cloud Resume Challenge personal website.

It is a handoff note, not final public website copy.

## Current Phase

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

## Live Production Details

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
- Counter entity: `PartitionKey = site`, `RowKey = main`, `Count = incrementing`

Do not document or expose connection strings, keys, tokens, or subscription IDs.

## Repository Shape

```text
personal_website/
├── README.md
├── TODO.md
├── WORKING_NOTES.md
├── AGENTS.md
├── frontend/
├── backend/
├── infra/
└── notes/
```

- `frontend/` contains the Hugo static site source.
- `backend/` contains the Azure Functions Python API.
- `infra/` is the Terraform work area for the next phase.
- `notes/` contains project notes, handoff docs, and troubleshooting material.

## Frontend

Frontend stack:

- Hugo static site generator
- Adritian Hugo theme
- Hugo Modules
- JavaScript visitor counter
- Azure Storage Static Website hosting
- Cloudflare custom domain, CDN/proxy, and TLS

Important files:

- `frontend/hugo.toml` controls site config, menus, metadata, theme imports, plugins, and output behavior.
- `frontend/content/home/home.md` composes the homepage with Adritian shortcodes.
- `frontend/content/footer/footer.md` controls the contact section rendered above the footer navigation.
- `frontend/layouts/partials/footer.html` is a project-level override that integrates the visitor counter into the footer.
- `frontend/static/js/visitor-count.js` chooses the visitor counter API URL:
  - local Hugo uses `http://localhost:7071/api/visitor-count`,
  - production uses the deployed Azure Function endpoint.
- `frontend/assets/css/custom.css` contains project visual overrides.

Deployment model:

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
- HTTP trigger route: `GET /api/visitor-count`
- Python package dependencies in `backend/requirements.txt`
- Cosmos DB Table API accessed through `azure-data-tables`

Important files:

- `backend/function_app.py` defines the visitor counter API.
- `backend/requirements.txt` includes `azure-functions` and `azure-data-tables`.
- `backend/local.settings.json` is local-only and ignored by Git.

The function:

1. Reads `AZURE_TABLE_CONNECTION_STRING` from environment settings.
2. Connects to table `VisitorCounter`.
3. Reads entity `PartitionKey = site`, `RowKey = main`.
4. Increments `Count`.
5. Writes the updated entity.
6. Returns JSON with the updated visitor count.

`AZURE_TABLE_CONNECTION_STRING` must exist only in local settings and Azure Function App settings. Never commit or document its value.

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

Python note:

- `py --version` works and points to Python 3.12.
- `python --version` may not work because Python is not directly on PATH.
- Use the virtual environment or `py` commands unless PATH is fixed.

## Completed Milestones

- Hugo + Adritian site scaffolded and customized.
- Homepage, about, experience, projects, blog placeholder, contact, and footer content personalized.
- Azure Storage Static Website hosting completed.
- Cloudflare DNS/CDN/TLS/proxy completed.
- Root domain redirects to `www`.
- Visitor counter frontend display added.
- Azure Functions Python API created and deployed.
- Cosmos DB Table API visitor count storage created.
- API configured through Function App app settings.
- CORS configured for local Hugo and live site.
- Live end-to-end visitor counter verified.

## Terraform Decision

Hitesh chose Terraform for IaC.

Decision:

- Terraform installed locally: `v1.15.3`.
- Build a fresh Terraform-managed Azure environment from scratch.
- Do not import or adopt the existing live resources.
- Do not use Terraform import for now.
- Existing production stays untouched.
- Terraform manages Azure infrastructure only.

This means the next engineer should not try to convert the current live resources into Terraform state.

## Cloudflare Decision

Cloudflare remains manually managed for now.

- Do not add the Cloudflare Terraform provider.
- Do not request or use Cloudflare API tokens.
- Cloudflare cache purge remains manual.
- Later, once Terraform-created Azure Storage hosting is tested, Cloudflare can be manually repointed to the new Azure Storage static website origin.
- Automated cache purge can be revisited later with a limited Cloudflare API token stored securely in GitHub Actions secrets.

## Security Rules

Never commit:

- `backend/local.settings.json`
- `.venv/`
- `__pycache__/`
- Azure secrets
- Cosmos DB connection strings
- Function keys
- Storage account keys
- Cloudflare API tokens
- GitHub tokens
- Azure credentials or subscription IDs

Frontend JavaScript must never talk directly to Cosmos DB. The browser calls the Azure Function API only.

## Immediate Next Steps

1. Add backend tests for visitor counter logic.
2. Plan Terraform in `infra/` for a fresh Azure environment.
3. Keep current production untouched while Terraform is developed and tested.
4. Later add CI/CD for frontend and backend deployment.
5. Create architecture diagram.
6. Write Cloud Resume Challenge case study/blog post.

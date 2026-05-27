# Azure Cloud Resume Challenge - Personal Website

This repository contains Hitesh Manani's Azure Cloud Resume Challenge project and personal portfolio website.

The site is a polished Hugo-based personal website that demonstrates hands-on Azure static hosting, serverless APIs, Python backend logic, database-backed state, source control, and the next phase of infrastructure as code and CI/CD.

Live site:

```text
https://www.hiteshmanani.com
```

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

The visitor counter is live. The browser calls the Azure Function API, the Python backend increments the Cosmos DB table entity, and the frontend displays the updated count in the footer.

## Current Live Resources

- Canonical domain: `https://www.hiteshmanani.com`
- DNS/CDN/TLS/proxy: Cloudflare
- Azure Storage account: `personalwebsitesacrc`
- Static website endpoint: `https://personalwebsitesacrc.z1.web.core.windows.net/`
- Azure Function App: `func-hm-crc`
- Visitor counter API: `https://func-hm-crc-eaene9aufsf4cmen.uaenorth-01.azurewebsites.net/api/visitor-count`
- Resource group: `crc-personal-website`
- Region: `UAE North`
- Cosmos DB Table API account: `hm-crc-cosmosdb`
- Cosmos table: `VisitorCounter`
- Counter entity: `PartitionKey = site`, `RowKey = main`, `Count = incrementing`

## Technical Stack

- Hugo static site generator
- Adritian Hugo theme
- JavaScript visitor counter
- Azure Storage Static Website hosting
- Azure Functions HTTP API
- Python backend
- Cosmos DB Table API
- Cloudflare DNS/CDN/TLS/proxy
- Git/GitHub source control
- Terraform planned for Infrastructure as Code

## Project Structure

```text
frontend/   Hugo static site source
backend/    Azure Functions Python API
infra/      Terraform Infrastructure as Code work area
notes/      Project notes, handoff docs, troubleshooting notes, and blog material
```

Hugo generates static output into `frontend/public/`. Azure Storage hosts the generated static files, not Hugo itself.

## Terraform Direction

Hitesh chose Terraform for the IaC phase.

Decision:

- Build a fresh Terraform-managed Azure environment from scratch.
- Do not import or adopt the current live resources.
- Do not use Terraform import for now.
- Keep existing production untouched while Terraform is developed and tested.
- Terraform manages Azure infrastructure only.
- Cloudflare remains manually managed for now.

Terraform installed locally: `v1.15.3`.

## Security Guardrails

Never commit secrets or local-only settings.

Do not commit:

- `backend/local.settings.json`
- `.venv/`
- `__pycache__/`
- `frontend/node_modules/`
- `frontend/public/`
- `frontend/resources/_gen/`
- `frontend/.hugo_build.lock`
- Azure credentials, Cosmos DB connection strings, Function keys, storage keys, Cloudflare tokens, GitHub tokens, or subscription IDs

`AZURE_TABLE_CONNECTION_STRING` exists only in local settings and Azure Function App settings. The frontend must never talk directly to Cosmos DB. Browser traffic must go through the Azure Function API.

## Next Work

The next phase is testing and Terraform IaC:

- Add backend tests for visitor counter logic.
- Design Terraform for a fresh Azure environment.
- Keep current production resources untouched during Terraform work.
- Later add CI/CD for frontend and backend deployment.
- Create the architecture diagram.
- Write the final Cloud Resume Challenge case study/blog post.

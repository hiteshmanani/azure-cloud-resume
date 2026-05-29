# Senior Engineer Handover

## Purpose

This is the primary handover for Hitesh Manani's Azure Cloud Resume Challenge personal website. It is written so another senior engineer, mentor, or Codex session can continue immediately without needing the previous chat history.

The repository is also a learning project. Keep explanations beginner-friendly and avoid hiding the Cloud Resume Challenge learning objectives behind excessive abstraction.

## Project Goal

Build a polished Hugo-based personal portfolio that also satisfies the Azure Cloud Resume Challenge.

The challenge requirements represented in this project are:

- Static website hosting on Azure Storage
- JavaScript visitor counter
- API layer between frontend and database
- Serverless backend
- Database-backed visitor count
- Tests
- Infrastructure as code
- Source control
- CI/CD
- Final architecture/write-up

Completed so far: static hosting, custom domain/HTTPS, JavaScript visitor counter, Azure Functions API, Cosmos DB Table API, Terraform-managed rebuild, and end-to-end validation of the Terraform environment.

Still remaining: stronger backend tests, CI/CD with GitHub Actions, architecture diagram, Cloudflare cutover decision, and final case study/blog post.

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

- `frontend/` contains the Hugo static site source and Adritian theme customizations.
- `backend/` contains the Python Azure Functions visitor counter API.
- `infra/` contains Terraform for the fresh Azure environment.
- `notes/` contains handoff, Cloudflare, content, and CI/CD planning notes.

Related notes:

- `notes/ci-cd-plan.md` documents the next GitHub Actions phase.
- `notes/static-hosting-domain-cloudflare.md` documents the current manual Cloudflare/public-domain setup.
- `notes/site-content-brief.md` documents content positioning and public site tone.

## Current Architecture

Original/manual production path:

```text
Browser
-> Cloudflare
-> Azure Storage Static Website
-> Hugo/JavaScript
-> Azure Function HTTP API
-> Python backend
-> Cosmos DB Table API
```

Terraform-managed test path:

```text
Browser
-> Azure Storage Static Website at https://sacrcprod001.z1.web.core.windows.net/
-> Hugo/JavaScript
-> Azure Function App func-crc-prod
-> Python backend
-> Cosmos DB Table API
```

Cloudflare has not been repointed to the Terraform-managed environment yet.

## Original Manual Production Environment

These resources were created/configured before the Terraform rebuild. Do not import them into Terraform unless the project owner explicitly changes direction.

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

Cloudflare details live in `notes/static-hosting-domain-cloudflare.md`.

## Terraform-Managed Environment

Terraform creates a fresh Azure environment from scratch. It does not import or adopt the original production resources.

Known Terraform-managed resources from code/docs:

- Resource group: `rg-crc-prod`
- Static website storage account: `sacrcprod001`
- Static website endpoint: `https://sacrcprod001.z1.web.core.windows.net/`
- Function App: `func-crc-prod`
- Function hosting plan: Flex Consumption
- Cosmos DB Table API account: `cosmos-crc-prod-001`
- Cosmos table: `VisitorCounter`

The Terraform-created static website has been loaded with Hugo output. Its visitor counter calls `https://func-crc-prod.azurewebsites.net/api/visitor-count`.

The Function App uses `AZURE_TABLE_CONNECTION_STRING` from Azure Function App settings. The secret value is not committed or documented.

## Frontend

Frontend stack:

- Hugo static site generator
- Adritian Hugo theme
- Hugo Modules
- Project-level layout and CSS overrides
- Plain JavaScript visitor counter

Important files:

- `frontend/hugo.toml` controls site config, menus, modules, plugins, output, SEO, and parameters.
- `frontend/content/` contains site content.
- `frontend/layouts/partials/footer.html` displays the visitor counter.
- `frontend/static/js/visitor-count.js` chooses the visitor counter API URL.
- `frontend/assets/css/custom.css` contains local visual overrides.

Deployment model:

```text
cd frontend
hugo
upload contents of frontend/public/ to Azure Storage $web container
```

Important: upload the contents of `public/`, not the `public` folder itself.

Generated folders such as `frontend/public/` and `frontend/resources/_gen/` must not be committed.

## Backend

Backend stack:

- Azure Functions Python v2 programming model
- Anonymous HTTP trigger
- `azure-functions`
- `azure-data-tables`
- Cosmos DB Table API

Important files:

- `backend/function_app.py` defines `GET /api/visitor-count`.
- `backend/requirements.txt` defines Python dependencies.
- `backend/host.json` defines Azure Functions host config.
- `backend/local.settings.json` is local-only and must not be committed.

Runtime behavior:

1. Reads `AZURE_TABLE_CONNECTION_STRING` from environment settings.
2. Connects to table `VisitorCounter`.
3. Tries to read entity `PartitionKey = site`, `RowKey = main`.
4. If the entity exists, increments `Count`.
5. If the entity is missing, creates it with `Count = 1`.
6. Returns JSON with `visitor_count`.

The frontend must call the Function API. It must never talk directly to Cosmos DB.

## Cosmos DB Table API Model

Table:

```text
VisitorCounter
```

Entity:

```text
PartitionKey = site
RowKey       = main
Count        = incrementing integer
```

Terraform creates the account/table infrastructure. The Python function owns the mutable counter entity.

## Terraform And Remote State

Terraform files live in `infra/`.

Important files:

- `infra/main.tf` defines Azure resources.
- `infra/variables.tf` defines input variables.
- `infra/terraform.tfvars` contains non-secret values currently used locally.
- `infra/outputs.tf` contains useful outputs.
- `infra/versions.tf` defines provider/backend requirements.
- `infra/.debug-prod.sh` is a local helper for backend config and command execution.

Remote state uses the Terraform `azurerm` backend. The backend block is intentionally empty in code; backend values are supplied at `terraform init` time by `infra/.debug-prod.sh`.

Known backend resource names appear in `infra/.debug-prod.sh`, which is ignored because it contains environment-specific values. Do not commit backend credentials or sensitive state.

Common local command pattern:

```bash
cd infra
./.debug-prod.sh plan
```

Open question / needs confirmation:

- Whether to keep using `.debug-prod.sh` long term, or replace it with documented `terraform init -backend-config=...` commands for CI.
- How backend config should be supplied securely in GitHub Actions.

## Security Rules

Never commit:

- Azure secrets
- Azure credentials
- Azure subscription IDs or tenant IDs
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

Connection strings belong in Azure Function App settings or a secure secret store. They do not belong in source code, committed Terraform variables, or public docs.

## Known Risks And Assumptions

- `func-crc-prod` is a Flex Consumption Function App. Deployment behavior for Python Flex Consumption should be confirmed before automating GitHub Actions.
- Backend tests are not yet strong enough for final completion.
- Terraform resource names/comments may need cleanup before CI/CD is added.
- `infra/.debug-prod.sh` removes `.terraform/` after commands, which can make local Terraform troubleshooting noisier.
- Cloudflare still points at the original/manual production environment.
- The Terraform environment has been tested, but it is not yet the canonical public domain.
- `frontend/hugo.toml` still has `baseURL = "https://www.hiteshmanani.com/"`; this is correct for final public use, but worth checking during Terraform endpoint testing.

## Next Phase: GitHub Actions CI/CD

Do not implement workflow YAML until the design is reviewed.

Planned workflows:

- Frontend workflow: on `main` pushes affecting `frontend/**`, build Hugo, upload generated output to the Terraform-managed Storage `$web` container, then smoke test the static website endpoint.
- Backend workflow: on `main` pushes affecting `backend/**`, set up Python, install dependencies, run tests, deploy to `func-crc-prod`, then smoke test the visitor-count API.
- Terraform workflow: on PRs or pushes affecting `infra/**`, run `terraform fmt -check`, `terraform init`, `terraform validate`, and `terraform plan`. Do not automate `terraform apply` yet.

Authentication should prefer GitHub Actions OIDC/federated credentials over long-lived Azure client secrets.

See `notes/ci-cd-plan.md` for the beginner-friendly breakdown.

## Cloudflare Cutover

Cloudflare remains manual for now.

Do not add:

- Cloudflare Terraform provider
- Cloudflare API token
- Automated Cloudflare purge

Cutover should happen only after Terraform-managed frontend and backend CI/CD are proven. The future public-domain path should point Cloudflare at the Terraform-managed static website origin while the frontend calls the Terraform-managed Function API.

## Immediate Next Steps

1. Review documentation changes and inspect `git diff`.
2. Clean up Terraform naming/comments/outputs if desired.
3. Add backend tests for the visitor counter create/increment paths.
4. Design and review GitHub Actions workflows before adding YAML.
5. Create architecture diagram.
6. Write final Cloud Resume Challenge case study/blog post.

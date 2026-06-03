# Azure Cloud Resume Challenge - Hitesh Manani

This repository is my completed Azure Cloud Resume Challenge project: a personal portfolio website built with Hugo, hosted on Azure Storage Static Website, fronted by Cloudflare, and extended with a serverless visitor counter.

Live site:

```text
https://www.hiteshmanani.com
```

The project is designed to be useful in two ways:

- As a public portfolio project that demonstrates practical Azure, infrastructure, CI/CD, and security decisions.
- As a learning reference for other cloud learners who want to understand how the pieces fit together.

## What This Project Demonstrates

- Static site generation with Hugo and the Adritian theme.
- Static website hosting on Azure Storage.
- Custom domain, DNS, CDN/proxy, and TLS through Cloudflare.
- A JavaScript visitor counter on the frontend.
- A Python Azure Functions HTTP API backend.
- Cosmos DB Table API for persistent visitor count storage.
- Terraform-managed Azure infrastructure.
- GitHub Actions CI/CD for frontend, backend, and infrastructure.
- GitHub Actions authentication to Azure using OIDC/federated credentials instead of long-lived client secrets.

## Architecture Overview

Current production request flow:

```text
Browser
-> Cloudflare DNS/CDN/proxy/TLS
-> Azure Storage Static Website
-> Hugo-generated HTML/CSS/JavaScript
-> Azure Function HTTP API
-> Python visitor counter backend
-> Azure Cosmos DB Table API
```

The public website is served from Azure Storage through Cloudflare. The visitor counter does not connect to the database from the browser. Instead, frontend JavaScript calls an anonymous HTTP endpoint on the Azure Function App, and the Function App updates the Cosmos DB Table API entity.

The detailed diagrams live in the public docs:

- [Production architecture](docs/architecture.md)
- [CI/CD flow](docs/ci-cd.md)
- [Manual-to-Terraform cutover](docs/domain-cloudflare.md)
- [Security](docs/security.md)

## Tech Stack

| Area | Technology | Purpose |
| --- | --- | --- |
| Frontend | Hugo | Generates the static portfolio website |
| Theme | Adritian Hugo theme | Base portfolio theme and layout system |
| Frontend assets | HTML, CSS, JavaScript | Static browser experience and visitor counter call |
| Hosting | Azure Storage Static Website | Serves generated static files from the `$web` container |
| Edge/DNS/TLS | Cloudflare | DNS, CDN/proxy, HTTPS, and root-to-www redirect |
| Backend | Python Azure Functions | HTTP API for visitor counter updates |
| Database | Azure Cosmos DB Table API | Stores the visitor counter entity |
| Infrastructure | Terraform | Provisions Azure resources reproducibly |
| CI/CD | GitHub Actions | Builds, validates, deploys, and smoke tests changes |
| Auth for CI/CD | GitHub OIDC to Azure | Avoids long-lived Azure client secrets in GitHub |

## Repository Structure

```text
.
├── .github/workflows/      GitHub Actions workflows
├── backend/                Python Azure Functions visitor counter API
├── docs/                   Public project documentation
├── frontend/               Hugo static site source
├── infra/                  Terraform Azure infrastructure
├── notes/                  Internal working notes and handoff material
├── .gitignore
└── README.md
```

The `notes/` folder contains working notes from the build process. Those files are useful history, but the public documentation starts with this README and the `docs/` folder.

## Frontend

The frontend lives in `frontend/` and is built with Hugo. Hugo reads content, layouts, static files, and theme dependencies, then generates static output into `frontend/public/`.

Important points:

- Edit Hugo source files, not `frontend/public/`.
- `frontend/public/` is generated output and should not be committed.
- The visitor counter script lives at `frontend/static/js/visitor-count.js`.
- The footer integration lives in `frontend/layouts/partials/footer.html`.
- In local development, the visitor counter calls `http://localhost:7071/api/visitor-count`.
- In production, it calls `https://func-crc-prod.azurewebsites.net/api/visitor-count`.

See [Frontend](docs/frontend.md).

## Backend API

The backend lives in `backend/` and uses the Azure Functions Python v2 programming model.

The API exposes:

```text
GET /api/visitor-count
```

The Function App reads `AZURE_TABLE_CONNECTION_STRING` from environment settings, connects to the `VisitorCounter` table, increments the entity for the main site counter, and returns JSON:

```json
{
  "visitor_count": 123
}
```

The connection string is not committed. It belongs in local settings for local development and in Azure Function App settings or another secure store for deployed environments.

See [Backend](docs/backend.md).

## Visitor Counter

The visitor counter uses a small API boundary on purpose:

```text
Browser JavaScript
-> Azure Function HTTP endpoint
-> Python backend
-> Cosmos DB Table API
```

The browser must not connect directly to Cosmos DB because that would expose credentials and database access to every site visitor. The Azure Function is the controlled server-side layer that owns the connection string and database update logic.

The counter record is stored in the `VisitorCounter` table as:

```text
PartitionKey = site
RowKey       = main
Count        = incrementing integer
```

If the entity does not exist, the backend creates it with a starting count of `1`.

## Infrastructure With Terraform

Terraform files live in `infra/`. Terraform manages the Azure infrastructure for the production environment, including:

- Resource group.
- Azure Storage account for static website hosting.
- Static website configuration and custom domain mapping.
- Cosmos DB Table API account and table.
- Storage for Azure Functions runtime/deployment packages.
- Linux Flex Consumption Function App.
- CORS configuration for the Function App.

Terraform remote state uses the `azurerm` backend. State files and plans must not be committed because Terraform state can contain sensitive values.

See [Infrastructure](docs/infrastructure.md).

## CI/CD With GitHub Actions

The repository includes three workflow groups:

- Frontend workflow: builds Hugo, uploads generated files to the Azure Storage `$web` container, and smoke tests the static site endpoint.
- Backend workflow: checks Python syntax, deploys the Function App, and smoke tests the visitor counter API.
- Infrastructure workflow: runs Terraform format, init, validate, plan, and apply.

GitHub Actions logs in to Azure using OIDC/federated credentials. This avoids storing long-lived Azure client secrets in GitHub.

See [CI/CD](docs/ci-cd.md).

## Security Notes

This project intentionally keeps secrets out of the repository:

- No Cosmos DB connection strings.
- No Azure tenant IDs, subscription IDs, client secrets, or storage keys.
- No Function keys.
- No Cloudflare API tokens.
- No `backend/local.settings.json`.
- No Terraform state or plan files.

Cloudflare is currently managed manually. If Cloudflare cache purge automation is added later, it should use a limited-scope Cloudflare API token stored securely outside the repository.

See [Security](docs/security.md).

## Cost Notes

This project is designed for a low-traffic personal portfolio:

- Azure Storage Static Website is a cost-effective static hosting origin.
- Azure Functions Flex Consumption keeps backend cost tied to usage.
- Cosmos DB Table API stores a tiny amount of data for the counter.
- Cloudflare Free is used for DNS, proxy/CDN, TLS, and redirects.

Costs still depend on region, usage, logs, retention, and Azure subscription settings. Anyone reusing this project should review Azure pricing and set budgets or alerts.

## Local Development

Prerequisites are documented in [Setup](docs/setup.md).

Frontend:

```bash
cd frontend
npm ci
hugo server
```

Open:

```text
http://localhost:1313/
```

Backend:

```bash
cd backend
python -m venv .venv
# Activate the virtual environment for your shell.
pip install -r requirements.txt
func start --cors http://localhost:1313
```

Local API:

```text
http://localhost:7071/api/visitor-count
```

Create `backend/local.settings.json` locally with your own placeholder values. Do not commit it.

## Deployment Overview

High-level deployment flow:

```text
Frontend source change
-> GitHub Actions
-> Hugo build
-> Upload frontend/public/ contents to Azure Storage $web
-> Smoke test static website endpoint

Backend source change
-> GitHub Actions
-> Python syntax check
-> Deploy Azure Function App
-> Smoke test visitor counter API

Infrastructure change
-> GitHub Actions
-> terraform fmt/init/validate/plan/apply
-> Azure infrastructure updated
```

Cloudflare DNS, proxy, TLS, and redirects are managed outside Terraform for now.

## Known Limitations And Future Improvements

- Mermaid diagrams are now embedded in the docs; they can be exported to PNG/SVG or recreated in draw.io for presentations.
- Backend unit tests can be expanded with mocked Table API calls.
- End-to-end browser smoke tests would provide stronger deployment confidence.
- Cloudflare cache purge is manual today.
- Monitoring and alerting can be improved.
- A full case study/blog post would make the project easier to discuss in interviews.

See [Roadmap](docs/roadmap.md).

## Learning Outcomes

This project helped me practice:

- Explaining cloud architecture clearly.
- Separating static hosting, serverless API, and database responsibilities.
- Using an API layer to protect database credentials.
- Managing infrastructure with Terraform.
- Designing CI/CD workflows with separate responsibilities and permissions.
- Using OIDC for safer GitHub Actions authentication to Azure.
- Making practical cost and platform tradeoffs, including Cloudflare instead of Azure Front Door for this use case.

## Credits And References

- [Cloud Resume Challenge](https://cloudresumechallenge.dev/)
- [Hugo](https://gohugo.io/)
- [Adritian Hugo theme](https://github.com/zetxek/adritian-free-hugo-theme)
- [Azure Storage Static Website documentation](https://learn.microsoft.com/azure/storage/blobs/storage-blob-static-website)
- [Azure Functions documentation](https://learn.microsoft.com/azure/azure-functions/)
- [Azure Cosmos DB Table API documentation](https://learn.microsoft.com/azure/cosmos-db/table/)
- [Terraform AzureRM provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [GitHub Actions OIDC with Azure](https://learn.microsoft.com/azure/developer/github/connect-from-azure-openid-connect)
- [Cloudflare documentation](https://developers.cloudflare.com/)

## Manual TODOs

- TODO: Optionally export Mermaid diagrams to `docs/images/` as PNG/SVG for richer visual presentation.
- TODO: Optionally create a polished draw.io architecture diagram for presentations or a case study.
- TODO: Add screenshots for Cloudflare DNS, Azure Storage static website, Function App settings, and GitHub Actions runs if desired.
- TODO: Verify whether legacy/manual Azure resources should be deleted after the rollback window.

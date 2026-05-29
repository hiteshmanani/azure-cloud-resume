# CI/CD Plan - GitHub Actions

## Purpose

This note documents the next planned phase for the Azure Cloud Resume Challenge project. It is a plan only. No GitHub Actions workflow YAML has been added yet.

The goal is to move from manual deployment to reviewed, repeatable GitHub Actions workflows for:

- Frontend build and static website deployment
- Backend test and Azure Functions deployment
- Terraform formatting, validation, and planning

Cloudflare remains manual for now.

## Beginner Concepts

CI means continuous integration. In this project, CI means GitHub automatically checks changes after code is pushed or opened in a pull request. Examples: install dependencies, run tests, run `terraform fmt -check`, and run `terraform validate`.

CD means continuous deployment. In this project, CD means GitHub automatically deploys approved changes to Azure, such as uploading Hugo output to Azure Storage or publishing the Python Function App.

GitHub Actions is GitHub's automation service. It runs workflows when events happen, such as a push to `main` or a pull request.

YAML is the configuration file format GitHub Actions uses. Workflow files usually live under `.github/workflows/` and describe triggers, jobs, steps, permissions, and commands.

A GitHub Actions runner is the temporary machine that executes the workflow. For this project, GitHub-hosted runners are likely enough.

Path filters limit workflows to relevant changes. For example, a frontend workflow should run when `frontend/**` changes, not when only Terraform docs change.

Frontend, backend, and Terraform workflows should be separate because they have different tools, risks, permissions, and deployment targets. A Hugo content change should not run Terraform. A Terraform change should not deploy backend code.

Terraform apply should not be automated too early because it changes cloud infrastructure. For the next phase, GitHub Actions should produce a plan for review. Automatic apply can be added later with manual approvals and stronger guardrails.

OIDC is preferred over long-lived Azure credentials because GitHub can request short-lived Azure tokens through a federated identity. This avoids storing permanent Azure client secrets in GitHub.

## Frontend Workflow Plan

Trigger:

- Pushes to `main`
- Only when `frontend/**` changes

Purpose:

- Build the Hugo site.
- Deploy generated static files to the Terraform-managed Azure Storage static website `$web` container.
- Smoke test the Terraform static website endpoint.

Expected high-level steps:

1. Check out the repository.
2. Set up Hugo at the required version.
3. Install any frontend dependencies if needed.
4. Run `hugo` from `frontend/`.
5. Authenticate to Azure using OIDC/federated credentials if possible.
6. Upload contents of `frontend/public/` to the `$web` container in `sacrcprod001`.
7. Smoke test `https://sacrcprod001.z1.web.core.windows.net/`.
8. Do not commit `frontend/public/`.

Acceptance criteria:

- Workflow only runs for frontend changes.
- Hugo build succeeds.
- Generated files are uploaded to the Terraform-managed Storage static website container.
- Static website endpoint returns a successful response.

Open question / needs confirmation:

- Exact Hugo version to pin in GitHub Actions.
- Whether npm install is required in CI for the current Adritian/Hugo build.
- Whether the workflow should delete old blobs before upload or only overwrite changed files.

## Backend Workflow Plan

Trigger:

- Pushes to `main`
- Only when `backend/**` changes

Purpose:

- Validate and deploy the Python Azure Functions backend.
- Smoke test the visitor counter endpoint.

Expected high-level steps:

1. Check out the repository.
2. Set up Python.
3. Install dependencies from `backend/requirements.txt`.
4. Run backend tests.
5. Authenticate to Azure using OIDC/federated credentials if possible.
6. Deploy to the Terraform-managed Function App `func-crc-prod`.
7. Smoke test `https://func-crc-prod.azurewebsites.net/api/visitor-count`.

Deployment options to evaluate:

- Prefer official Azure Functions GitHub Actions if suitable for Python Flex Consumption.
- If official action behavior is problematic, document and use Azure Functions Core Tools or Azure CLI zip deployment.

Important notes:

- Backend tests still need to be added/strengthened before this workflow should be considered complete.
- `AZURE_TABLE_CONNECTION_STRING` should already exist as an Azure Function App setting or be supplied from a secure secret store.
- Do not put the connection string in GitHub Actions YAML.

Acceptance criteria:

- Workflow only runs for backend changes.
- Tests run before deployment.
- Function deployment succeeds.
- Visitor counter API returns JSON containing `visitor_count`.

Open question / needs confirmation:

- Best deployment mechanism for Python Flex Consumption in GitHub Actions.
- Python version to pin in Actions, matching the Function runtime.
- Whether smoke tests should increment the production-like Terraform counter or call a separate test endpoint/table in the future.

## Terraform Workflow Plan

Trigger:

- Pull requests that change `infra/**`
- Pushes to `main` that change `infra/**`

Purpose:

- Check Terraform formatting and validity.
- Produce a reviewed Terraform plan.
- Avoid automatic infrastructure changes for now.

Expected high-level steps:

1. Check out the repository.
2. Set up Terraform.
3. Authenticate to Azure using OIDC/federated credentials if possible.
4. Run `terraform fmt -check` in `infra/`.
5. Run `terraform init` with the existing remote backend configuration.
6. Run `terraform validate`.
7. Run `terraform plan`.
8. Publish or display the plan for human review.

Do not add automatic `terraform apply` yet.

Why no automatic apply yet:

- Terraform changes real Azure resources.
- The project owner is still learning Terraform and Azure deployment workflows.
- Plans should be reviewed before changes are applied.
- Manual approval can be added later after the workflow and permissions are trusted.

Open question / needs confirmation:

- How backend config should be supplied in GitHub Actions without using the local `infra/.debug-prod.sh` script.
- Whether to create a dedicated Azure federated identity/service principal for Terraform.
- How to separate Terraform permissions from frontend/backend deployment permissions.

## Cloudflare Cutover Plan

Cloudflare remains manual for now.

Do not add:

- Cloudflare Terraform provider
- Cloudflare API token
- Automated Cloudflare cache purge

Future cutover should happen only after:

- Terraform-managed frontend CI/CD is proven.
- Terraform-managed backend CI/CD is proven.
- Function App API is stable.
- Static website endpoint is stable.
- Rollback plan is clear.

Future cutover target:

- Public domain should point to the Terraform-managed static website origin.
- Frontend JavaScript should call the Terraform-managed Function API.

Open question / needs confirmation:

- Exact Cloudflare DNS changes for cutover.
- Whether the original production Azure resources should be retained for rollback after cutover.
- Whether Cloudflare cache purge should remain manual after cutover or be automated later with a limited-scope token.

## Security Rules

Never commit:

- Azure secrets
- Azure client secrets
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
- debug scripts containing environment-specific values

Database connection strings belong in Azure Function App settings, GitHub Actions secrets only if unavoidable, or a secure secret store. They do not belong in source code.

Frontend JavaScript must never connect directly to Cosmos DB.

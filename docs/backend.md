# Backend

The backend is a Python Azure Functions app that provides the visitor counter API. It is intentionally small: one HTTP endpoint owns the counter update and keeps Cosmos DB access server-side.

## Source Layout

| Path | Purpose |
| --- | --- |
| `backend/function_app.py` | Defines the HTTP-triggered visitor counter function |
| `backend/requirements.txt` | Python dependencies for Azure Functions and Azure Tables |
| `backend/host.json` | Azure Functions host configuration |
| `backend/.funcignore` | Excludes local-only files from deployment packages |

## API

```text
GET /api/visitor-count
```

Response:

```json
{
  "visitor_count": 123
}
```

The endpoint is anonymous because it is called by the public website. The database connection remains protected because the Function App holds the Cosmos DB Table API connection string in server-side application settings.

## Runtime Behavior

On each request, the Function:

1. Reads `AZURE_TABLE_CONNECTION_STRING` from the Function App environment.
2. Connects to the `VisitorCounter` table.
3. Reads the `site/main` counter entity.
4. Increments `Count` if the entity exists.
5. Creates the entity with `Count = 1` if it is missing.
6. Returns the updated count as JSON.

Counter entity:

```text
PartitionKey = site
RowKey       = main
Count        = incrementing integer
```

## Configuration

Required application setting:

```text
AZURE_TABLE_CONNECTION_STRING=<COSMOS_CONNECTION_STRING>
```

Local development uses `backend/local.settings.json`. Production uses Azure Function App application settings. The frontend never receives this value.

## Local Development

```bash
cd backend
python -m venv .venv
pip install -r requirements.txt
func start --cors http://localhost:1313
```

Local endpoint:

```text
http://localhost:7071/api/visitor-count
```

The CORS flag allows the Hugo dev server to call the local Function host during development.

## Deployment Workflow

The backend workflow runs a Python syntax check, authenticates to Azure through OIDC and Azure RBAC, deploys the `backend/` folder to `func-crc-prod`, and smoke tests the deployed endpoint.

The smoke test calls the production API and checks for `visitor_count` in the response. That validates the deployed Function path, but it also increments the counter once per successful backend deployment.

## Operational Notes

- If the endpoint fails before returning JSON, check the Function App setting for `AZURE_TABLE_CONNECTION_STRING`.
- If the endpoint returns an error after connecting, check the Cosmos DB Table API account and the `VisitorCounter` table.
- If the browser call fails but `curl` succeeds, check Function App CORS settings.
- If deployment fails, check the backend workflow logs and the Azure RBAC permissions for the backend deployment identity.

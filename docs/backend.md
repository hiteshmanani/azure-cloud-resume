# Backend

The backend is a Python Azure Functions app. It lives in `backend/` and provides the HTTP API used by the frontend visitor counter.

## Source Layout

Important files:

- `backend/function_app.py` defines the HTTP-triggered visitor counter function.
- `backend/requirements.txt` lists Python dependencies.
- `backend/host.json` contains Azure Functions host configuration.
- `backend/.funcignore` excludes local-only files from deployment packages.
- `backend/local.settings.json` is used only for local development and must not be committed.

## Endpoint

The backend exposes:

```text
GET /api/visitor-count
```

The route is anonymous because the public website needs to call it from a visitor's browser. The backend still protects the database because the Cosmos DB connection string stays server-side in Function App settings.

## Runtime Behavior

On each request, the function:

1. Reads `AZURE_TABLE_CONNECTION_STRING` from environment variables.
2. Connects to the `VisitorCounter` table.
3. Reads the entity with `PartitionKey = site` and `RowKey = main`.
4. Converts the stored `Count` value to an integer.
5. Increments and updates the entity.
6. Creates the entity with `Count = 1` if it does not exist.
7. Returns JSON with the new count.

Response shape:

```json
{
  "visitor_count": 123
}
```

## Environment Variables

Required:

```text
AZURE_TABLE_CONNECTION_STRING=<COSMOS_CONNECTION_STRING>
```

Do not expose or commit the connection string. Store it in:

- `backend/local.settings.json` for local development.
- Azure Function App application settings for production.
- A secure secret store if the project later adopts one.

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

When running the frontend locally at `http://localhost:1313`, the `--cors` flag allows the browser to call the local Function host.

## Deployment

The backend GitHub Actions workflow:

- Checks out the repository.
- Sets up Python 3.12.
- Runs a syntax check with `python -m compileall backend`.
- Logs in to Azure using OIDC.
- Confirms the target Function App exists.
- Deploys the `backend/` folder to Azure Functions.
- Smoke tests the visitor counter API.

The production Function App name is documented as:

```text
func-crc-prod
```

## Common Troubleshooting

- Missing `AZURE_TABLE_CONNECTION_STRING`: the function will fail before it can connect to Cosmos DB.
- Wrong table name or account: the function may fail to read or create the counter entity.
- CORS failure: the browser call is blocked before the response reaches frontend JavaScript.
- Deployment failure: confirm the GitHub Actions identity has permission to deploy to the Function App.
- Smoke test increments production count: the current smoke test calls the real anonymous endpoint, so it increments the visitor counter once per backend deployment.

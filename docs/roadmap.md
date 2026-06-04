# Roadmap

Azure Cloud Resume is live. The remaining work focuses on test depth, deployment polish, and operations.

## Testing

- Add stronger Python unit tests for visitor counter create and increment paths.
- Mock Cosmos DB Table API calls in backend tests.
- Add API response-shape tests.
- Add end-to-end smoke tests for the deployed website and visitor counter.
- Add a browser-level check that confirms the footer counter renders after deployment.

## CI/CD Improvements

- Consider GitHub environment approvals for Terraform apply.
- Add Cloudflare cache purge automation with a narrowly scoped token. This is in progress and not yet part of the deployment workflow.

## Operations

- Add monitoring and alerts for the Function App.
- Review Application Insights settings and log retention.
- Document the operational checks used after frontend, backend, and infrastructure deployments.

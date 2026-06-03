# Roadmap

The core Azure Cloud Resume Challenge implementation is live. The remaining improvements are mostly about polish, testing depth, operations, and storytelling.

## Documentation And Presentation

- Export Mermaid diagrams to PNG/SVG for richer visual presentation if desired.
- Optionally create a polished draw.io architecture diagram for presentations or blog posts.
- Write a Cloud Resume Challenge case study or blog post.
- Add selected screenshots after checking that they reveal no secrets.
- Prepare a short interview-ready explanation of the architecture and tradeoffs.

## Testing

- Add stronger Python unit tests for the visitor counter.
- Mock Cosmos DB Table API calls for create and increment paths.
- Add API response-shape tests.
- Add end-to-end smoke tests for the deployed website and visitor counter.
- Consider a browser-based test that checks the footer counter renders successfully.

## CI/CD Improvements

- Consider GitHub environment approvals for Terraform apply.
- Add clearer workflow summaries or deployment notes.
- Add optional Cloudflare cache purge automation with a limited token.
- Keep path filters so frontend, backend, and infrastructure changes remain separate.

## Domain And Edge

- Harden root/apex redirect behavior if needed.
- Document final DNS screenshots.
- Keep Cloudflare as the current edge layer.
- Optionally compare Azure Front Door for learning purposes, while keeping Cloudflare as the final production choice unless the project direction changes.

## Operations

- Add monitoring and alerts for the Function App.
- Review Application Insights settings and log retention.
- Add budget alerts in Azure.
- Document a simple rollback plan for frontend, backend, and infrastructure.

## Website Quality

- Run accessibility checks.
- Run performance checks.
- Review SEO metadata and social preview images.
- Replace placeholder blog/theme sample content if any remains visible.
- Improve portfolio project writeups over time.

## Analytics And Logging

- Consider privacy-conscious analytics.
- Keep visitor counter separate from full analytics.
- Avoid logging secrets or personally sensitive data.
- Document any future analytics choice clearly.

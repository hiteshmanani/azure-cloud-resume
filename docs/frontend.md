# Frontend

The frontend is a Hugo static site. Hugo takes the source files in `frontend/`, renders the site, and produces static output that Azure Storage can serve without an application server.

## Source Layout

| Path | Purpose |
| --- | --- |
| `frontend/hugo.toml` | Site configuration, menus, modules, output settings, and build behavior |
| `frontend/content/` | Markdown content used to generate pages |
| `frontend/layouts/` | Project-specific layout overrides |
| `frontend/assets/` | CSS and image assets processed by Hugo |
| `frontend/static/` | Files copied directly into the generated site |
| `frontend/static/js/visitor-count.js` | Browser script for the visitor counter |
| `frontend/layouts/partials/footer.html` | Footer markup that includes the visitor counter target element |

## Build Output

`frontend/public/` is not a source directory. Hugo creates it when the site is built locally or in CI.

```text
frontend source files
-> hugo build
-> frontend/public/
-> upload generated files to Azure Storage $web
```

If `frontend/public/` is missing in a fresh clone, that is expected. It appears after running `hugo` or `hugo --minify`.

## Run Locally

```bash
cd frontend
npm ci
hugo server
```

Open:

```text
http://localhost:1313/
```

`npm ci` installs frontend build dependencies used by the Hugo site. Hugo Modules use Go to resolve the theme module.

## Build For Deployment

```bash
cd frontend
hugo --minify
```

The build writes the deployable static site to:

```text
frontend/public/
```

## Visitor Counter Integration

The footer contains a placeholder element for the count:

```html
<span id="visitor-count">--</span>
```

The browser script chooses the API endpoint based on where the site is running:

| Environment | API endpoint |
| --- | --- |
| Local Hugo server | `http://localhost:7071/api/visitor-count` |
| Production | `https://func-crc-prod.azurewebsites.net/api/visitor-count` |

The API returns JSON with `visitor_count`. If the request fails, the page keeps a safe fallback value so the portfolio still renders.

## Deployment

The frontend workflow builds the site and uploads the generated files to the Azure Storage Static Website `$web` container.

Correct storage shape:

```text
$web/index.html
$web/css/
$web/js/
$web/img/
```

Incorrect storage shape:

```text
$web/public/index.html
```

The distinction matters because Azure Storage serves files from the container root. The generated files inside `frontend/public/` should become the root of `$web`.

## Operational Notes

- If styles or scripts are missing after deployment, confirm the build completed and the generated files were uploaded to the container root.
- If the visitor counter shows the fallback value, check the browser network request and the Function App logs.
- If a previous version remains visible, check Cloudflare cache and the Azure Storage `$web` contents.

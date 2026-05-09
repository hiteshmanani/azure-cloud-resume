# TODO

## Priority Tasks

1. Verify deployment-readiness cleanup.
   - From `frontend/`, run `hugo --cleanDestinationDir`.
   - Then run `hugo`.
   - Confirm stale language routes such as `/fr/`, `/es/`, `/ar/`, and `/he/` are gone from `frontend/public/`.
   - Confirm `/index.json` does not include old demo content.

2. Review the site locally.
   - From `frontend/`, run `hugo server`.
   - Open `http://localhost:1313/`.
   - Check footer links: Home, About, Projects, Blog, Now, Contact.
   - Check `/blog/`, `/showcase/`, `/search/`, and `/now/`.
   - Search for terms like `article`, `Adritian`, `Radity`, `Asgardia`, and `testimonial`.

3. Review Git diff manually.
   - If Git safe-directory protection blocks status, run:

```powershell
git config --global --add safe.directory C:/Users/Asus/Desktop/DEV/personal_website
```

   - Then run:

```powershell
git status
git diff
```

4. SEO follow-up pass.
   - Confirm final `baseURL`.
   - Replace placeholder/social preview image with a final branded OG image if desired.
   - Review page titles and descriptions.
   - Review sitemap and robots output.
   - Add external indexing setup after deployment, such as Google Search Console.
   - Remember: SEO improves discoverability but does not guarantee ranking first.

5. Future Azure Cloud Resume Challenge work.
   - Azure Storage static website hosting.
   - JavaScript visitor counter.
   - Azure Functions HTTP API.
   - Python backend logic.
   - Serverless database for visitor count storage.
   - Unit tests.
   - Bicep infrastructure as code.
   - GitHub Actions CI/CD.
   - Custom domain and HTTPS.
   - Architecture diagram.
   - Final blog post and interview-ready explanation.

## Completed

- Personalized homepage hero/about content for Hitesh.
- Added Hitesh profile images.
- Restored Education with Heriot-Watt University.
- Hid Skills from visible nav/buttons without deleting `frontend/content/skills`.
- Updated header brand to Hitesh Manani.
- Hid visible language selectors.
- Removed unused homepage/footer demo sections.
- Configured footer contact form with Formspree endpoint.
- Added project-level CSS visual polish.
- Replaced visible English experience content with Contango/QData and Bespin Global.
- Added ADQ and Bespin Global logos to experience entries.
- Added homepage buttons for All Experience, LinkedIn, and View Resume.
- Changed top nav `Portfolio` to `Experience`.
- Repurposed `/showcase/` as `Projects` with three placeholders.
- Removed hardcoded Adritian showcase CTA with a local layout override.
- Renamed top nav `How to` to `Blog`.
- Added one visible Cloud Resume Challenge blog placeholder post.
- Draft-hidden English demo blog posts.
- Disabled blog categories sidebar for now.
- Replaced main Adritian demo metadata in `hugo.toml` and `i18n/en.yaml`.
- Removed disabled non-English language blocks from `hugo.toml` for V1.
- Updated English footer menu to include Projects, Blog, Now, and Contact.
- Draft-hidden demo `articles`, `news`, `client-work`, `testimonial`, old `projects`, and demo author pages.
- Consolidated search around one canonical `/search/` page.
- Added `/now/` page.
- Enabled robots output and improved basic SEO metadata.

## Ongoing Rules

- Do not edit theme module internals unless necessary.
- Prefer hiding or drafting demo content before deleting it.
- Do not commit or push from Codex.
- Do not commit generated or dependency folders:
  - `frontend/node_modules/`
  - `frontend/public/`
  - `frontend/resources/_gen/`
  - `frontend/.hugo_build.lock`
  - `.venv/`
  - `__pycache__/`
- Do not commit secrets, keys, tokens, connection strings, credentials, subscription IDs, or local settings.

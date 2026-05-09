# Working Notes

## Project Goal

This repo is Hitesh Manani's Hugo + Adritian personal website for the Azure Cloud Resume Challenge.

The visible V1 site should be a polished personal portfolio and a credible Cloud Resume Challenge project. It positions Hitesh around Azure cloud engineering, AI platform delivery, customer-facing implementation, product assurance, stakeholder communication, enterprise rollout, and solutions/customer success engineering roles.

Later Cloud Resume Challenge work still needs Azure Storage static website hosting, JavaScript visitor counter, Azure Functions API, database-backed visitor count, tests, infrastructure as code, CI/CD, custom domain/HTTPS, architecture explanation, and final write-up.

## Current Status

Current phase: deployment-readiness cleanup for the frontend.

The site runs locally from `frontend/`:

```powershell
hugo server
```

Local URL:

```text
http://localhost:1313/
```

Azure deployment, backend visitor counter, database, IaC, and CI/CD are not implemented yet.

## Codebase Shape

- `frontend/` contains the Hugo static site source. Hugo builds static output into `frontend/public/`.
- `frontend/hugo.toml` controls site metadata, menus, English language config, search JSON output, blog settings, theme imports, robots output, and plugins.
- `frontend/content/home/home.md` composes the homepage using Adritian shortcodes.
- `frontend/content/footer/footer.md` controls the footer contact section; footer navigation comes from `hugo.toml`.
- `frontend/content/experience/` contains experience page/index content. `job-1.md` and `job-2.md` are the real visible English entries.
- `frontend/content/showcase.md` and `frontend/data/showcase.yml` power the visible Projects page at `/showcase/`.
- `frontend/content/blog/` has one visible Cloud Resume Challenge placeholder post and draft-hidden demo posts.
- `frontend/content/now.md` is the personal `/now/` page.
- `frontend/content/search.md` is the intended canonical `/search/` page.
- `frontend/layouts/partials/experience-description.html` is a project-level override for experience buttons.
- `frontend/layouts/_default/showcase.html` is a project-level override that removes the Adritian showcase CTA.
- `frontend/assets/css/custom.css` contains local visual overrides.
- `frontend/static/files/hitesh-resume.pdf` is the public resume asset served as `/files/hitesh-resume.pdf`.
- `backend/` and `infra/` are future Cloud Resume Challenge backend/IaC areas and are not implemented yet.

## Completed Work

- Personalized homepage hero/about, restored Education, and hid Skills from nav/buttons.
- Configured Formspree contact endpoint.
- Added Hitesh images and company logos.
- Replaced English experience with Contango/QData and Bespin Global.
- Added Experience, Projects, Blog, resume, LinkedIn, and GitHub links.
- Repurposed `/showcase/` into Projects with three placeholders.
- Added one Cloud Resume Challenge blog placeholder and draft-hidden English demo posts.
- Replaced core Adritian metadata with Hitesh metadata.
- Removed disabled non-English language blocks from `hugo.toml` for V1 while keeping translation/content files for reference.
- Added Blog and Now to the English footer menu.
- Draft-hidden remaining demo sections: articles, news, client-work, testimonial, old projects, and demo author pages.
- Consolidated search around one intended `/search/` page and draft-hidden duplicate search files.
- Added `/now/` page.
- Enabled `robots.txt` generation and pointed OG/social image metadata at an existing static image.

## Key Decisions

- Keep changes small and beginner-safe.
- Prefer draft/hide before deleting demo content.
- Do not edit theme module internals; use local project overrides in `frontend/layouts/`.
- Keep the V1 site English-only.
- Keep non-English translation/content files for reference unless a later cleanup explicitly removes them.
- Use Formspree Basic HTML, not React/Ajax.
- Do not expose phone number, secrets, credentials, subscription IDs, or confidential customer details.
- Do not commit or push from Codex.

## Git Status Note

Git status may be blocked by safe-directory protection.

The user should run this once if needed:

```powershell
git config --global --add safe.directory C:/Users/Asus/Desktop/DEV/personal_website
```

Then review:

```powershell
git status
git diff
```

## Known Issues, Risks, And Open Questions

- `frontend/public/` is generated output and can contain stale routes unless rebuilt with `hugo --cleanDestinationDir`.
- SEO is improved but not finished. Final canonical domain, final OG image, sitemap/robots review, page descriptions, structured data, external indexing, useful content, backlinks, and time all affect discoverability.
- Ranking first in search is not guaranteed.
- The Cloud Resume Challenge backend, visitor counter, database, IaC, CI/CD, Azure hosting, and final write-up are still future work.

## Next Tasks In Priority Order

1. Verify the cleanup build:
   - run `hugo --cleanDestinationDir` from `frontend`,
   - run `hugo`,
   - verify `/fr/`, `/es/`, `/ar/`, and `/he/` are not generated,
   - verify `/index.json` does not include old demo content.
2. Review the site locally with `hugo server`.
3. Inspect `git diff` and confirm the cleanup changes are understandable.
4. Do a second SEO/content pass later:
   - final domain/baseURL confirmation,
   - final OG image,
   - stronger page-specific descriptions,
   - structured person/project data if useful,
   - Google Search Console and indexing setup after deployment.
5. Start the Azure deployment phase:
   - Azure Storage static website hosting,
   - generated `public/` upload/deploy flow,
   - visitor counter frontend placeholder,
   - Azure Functions API,
   - database-backed count,
   - tests,
   - Bicep,
   - GitHub Actions.

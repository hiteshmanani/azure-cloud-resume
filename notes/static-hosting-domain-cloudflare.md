# Static Hosting, Custom Domain, HTTPS, and Cloudflare Setup

## Milestone status

Completed.

The Hugo static site is live at:

https://www.hiteshmanani.com

The root domain redirects to the www domain.

## Final architecture

User browser
→ Cloudflare edge/CDN/proxy
→ Azure Storage static website endpoint
→ $web container
→ Hugo-generated static files

## Hosting model

The site is generated with Hugo, but Hugo itself is not hosted in Azure.

The deployment flow is:

Hugo source files
→ `hugo`
→ `frontend/public/`
→ upload contents of `public/` to Azure Storage `$web`

Azure Storage serves only static files such as HTML, CSS, JavaScript, images, and assets.

## Azure resources

Storage account:

`personalwebsitesacrc`

Static website hosting:

Enabled

Static website container:

`$web`

Azure Storage static website endpoint:

`https://personalwebsitesacrc.z1.web.core.windows.net/`

Azure Storage custom domain:

`www.hiteshmanani.com`

The canonical domain is:

`https://www.hiteshmanani.com`

## Manual build and deployment commands

Run from the frontend folder:
bash
cd ~/Desktop/DEV/personal_website/frontend
hugo

This generates:

frontend/public/

Clear old files from Azure Storage:

az storage blob delete-batch \
  --account-name personalwebsitesacrc \
  --source '$web' \
  --auth-mode login

Upload the new Hugo build:

az storage blob upload-batch \
  --account-name personalwebsitesacrc \
  --destination '$web' \
  --source ./public \
  --auth-mode login \
  --overwrite

Important: upload the contents of public/, not the public folder itself.

Correct Azure blob structure:

$web/index.html
$web/assets/
$web/blog/
$web/css/
$web/images/
$web/js/

Wrong structure:

$web/public/index.html
Azure RBAC issue encountered

Initial upload failed because the user had Azure management-plane permissions but not storage data-plane permissions.

The fix was assigning:

Storage Blob Data Owner

Lesson:

Azure subscription Owner permissions do not automatically mean blob upload permissions. Azure Storage separates management-plane access from data-plane access.

Domain and DNS model

Namecheap is the domain registrar.

Cloudflare is the authoritative DNS provider, CDN/reverse proxy, and TLS termination layer.

Azure Storage is the static website origin.

Cloudflare nameservers:

gabe.ns.cloudflare.com
may.ns.cloudflare.com
Cloudflare DNS records

Main website record:

Type: CNAME
Name: www
Target: personalwebsitesacrc.z1.web.core.windows.net
Proxy status: Proxied
TTL: Auto

Apex/root redirect support record:

Type: A
Name: @
Value: 192.0.2.1
Proxy status: Proxied
TTL: Auto

The apex record exists so Cloudflare can receive requests for hiteshmanani.com and apply the redirect rule. The placeholder IP is not serving the website.

Email forwarding records imported from Namecheap should remain DNS only.

SPF TXT record should also remain DNS only.

HTTPS and TLS

Cloudflare SSL/TLS mode:

Full

Meaning:

Browser → Cloudflare: HTTPS
Cloudflare → Azure Storage origin: HTTPS

Do not use Flexible mode because it may leave Cloudflare-to-origin traffic unencrypted.

Cloudflare Universal SSL is active for:

*.hiteshmanani.com
hiteshmanani.com

Settings enabled:

Always Use HTTPS
Automatic HTTPS Rewrites
Root-to-www redirect

Cloudflare redirect rule:

Source:

https://hiteshmanani.com/*

Target:

https://www.hiteshmanani.com/${1}

Status code:

301 Permanent Redirect

Preserve query string:

Enabled

Expected behavior:

https://www.hiteshmanani.com  -> works
http://www.hiteshmanani.com   -> redirects to https://www.hiteshmanani.com
https://hiteshmanani.com      -> redirects to https://www.hiteshmanani.com
http://hiteshmanani.com       -> redirects to https://www.hiteshmanani.com
Important lesson: DNS-only vs Proxied

Cloudflare DNS only:

Cloudflare only answers DNS. Browser goes directly to Azure Storage. Cloudflare certificate is not used.

Cloudflare Proxied:

Browser goes to Cloudflare. Cloudflare presents the SSL certificate. Cloudflare fetches the website from Azure Storage.

The www CNAME must be Proxied for Cloudflare HTTPS to work.

Email MX and TXT records should remain DNS only.

Why Cloudflare was used instead of Azure Front Door

Azure Front Door was considered for the custom-domain HTTPS layer.

For a low-traffic personal portfolio site, the fixed monthly cost was not justified.

Final decision:

Use Azure Storage Static Website for the required Azure hosting layer, and Cloudflare Free for DNS, CDN/proxy, TLS, and redirects.

Interview/blog framing:

I evaluated Azure Front Door for the custom-domain HTTPS layer, but for a low-traffic personal portfolio the fixed monthly cost was not justified. I kept Azure Storage as the required Azure static hosting origin and used Cloudflare’s free DNS/CDN/TLS layer for custom-domain HTTPS, documenting the tradeoff between Azure-native purity and practical cost control.

Final verification checklist
https://www.hiteshmanani.com loads successfully.
Browser shows valid HTTPS certificate.
http://www.hiteshmanani.com redirects to HTTPS.
https://hiteshmanani.com redirects to https://www.hiteshmanani.com.
http://hiteshmanani.com redirects to https://www.hiteshmanani.com.
Hugo baseURL is set to https://www.hiteshmanani.com/.
Azure Storage custom domain is www.hiteshmanani.com.
Cloudflare www CNAME is Proxied.
Email records remain DNS only.

## 4. Commit it

Run this in **Git Bash / VS Code terminal** from the repo root:
bash
cd ~/Desktop/DEV/personal_website
git add notes/static-hosting-domain-cloudflare.md
git commit -m "Document static hosting and Cloudflare domain setup"
git push
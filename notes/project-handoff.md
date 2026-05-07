# Project Handoff

## Purpose of this file

This file gives Codex technical context about the current state of my Azure Cloud Resume Challenge project.

It summarizes what has already been completed, what tools are installed, what decisions have been made, and what the next likely steps are.

This is not final website content. It is project context for implementation support.

## Project

Project name: Azure Cloud Resume Challenge personal website

Repository purpose:

Build a polished personal portfolio website that satisfies the Azure version of the Cloud Resume Challenge.

The website should be a personal website first and a resume site second. It should include professional positioning, experience, projects, Cloud Resume Challenge documentation, blog/technical notes, contact links, and eventually a resume download.

## Current phase

Current phase: Frontend foundation / Hugo theme customization

We have completed initial developer setup and moved from a basic static HTML/CSS/JS prototype to a Hugo + Adritian static site.

We are not yet deploying to Azure.

We are not yet building the visitor counter backend.

We are not yet creating Azure resources.

## Current project structure

The repo currently uses this structure:
personal_website/
├── AGENTS.md
├── README.md
├── .gitignore
├── frontend/
├── backend/
├── infra/
└── notes/
Folder meaning:

frontend/ contains the Hugo static site source.
backend/ will later contain the Azure Functions API.
infra/ will later contain Infrastructure as Code, likely Bicep.
notes/ contains project notes, content briefs, troubleshooting notes, and future blog material.
Frontend stack

The frontend currently uses:

Hugo static site generator
Adritian Hugo theme
Hugo Modules
Go for Hugo module support
Node.js and npm for theme dependencies
Local preview with hugo server

The site currently runs locally at:
http://localhost:1313/

Important architecture clarification

Azure Storage will not host Hugo itself.

The deployment flow later should be:
Hugo source files -> hugo build -> public/ output folder -> upload contents of public/ to Azure Storage static website container

The generated static files are what Azure Storage will host.

Tools installed and verified

The following tools have been installed and verified:

VS Code
Azure Tools extension for VS Code
Git
Azure CLI
Azure Functions Core Tools
Hugo Extended
Go
Node.js
npm
Python available through the Windows py launcher
Codex extension in VS Code

Known Python note:

py --version works and currently points to Python 3.12.
python --version does not currently work because Python is not on PATH directly.
This is not currently blocking frontend work.
Later backend work may use py commands unless Python PATH is fixed.
Git status and history

A private GitHub repository has been created and connected as origin.

The main branch is main.

A Git tag was created:
basic-html-baseline

This tag marks the simple hand-written HTML/CSS/JS frontend before replacing it with Hugo.

Important commits completed so far include:

initial project structure and static website files
initial README
basic personal website HTML structure
Hugo site scaffold
Adritian Hugo theme baseline
Codex project instructions through AGENTS.md
website content brief through notes/site-content-brief.md

The user manually controls Git commits and pushes.

Codex should not commit or push.

Important setup issue already solved

When installing Adritian starter content, the Node helper script failed in Windows PowerShell with: Error: spawnSync rm ENOENT

Likely cause:

The script tried to run Unix-style rm, which was not available as an executable in PowerShell.

Fix used:

Cleaned up failed temp folder.
Opened Git Bash.
Ran the content download script from Git Bash.
Then ran Hugo server again.

Result:

The Adritian site successfully opened at: http://localhost:1313/

Important .gitignore rules

The repo should not commit generated or dependency folders.

The .gitignore includes rules for:

Python cache files
virtual environments
Azure Functions local settings
OS/editor files
Hugo generated output
Hugo resources
Hugo build lock
frontend node_modules

Do not commit:
frontend/node_modules/
frontend/public/
frontend/resources/_gen/
frontend/.hugo_build.lock
local.settings.json
.venv/
__pycache__/
Never commit secrets, keys, tokens, credentials, connection strings, Azure subscription IDs, or local settings containing secrets.

Current content context

Before making major content edits, read: notes/site-content-brief.md

That file contains:

professional positioning
experience summary
projects to feature
skills categories
blog direction
Cloud Resume Challenge page direction
contact/resume guidance
personal layer / outside work guidance
tone and privacy rules

Do not copy the whole brief directly into the website. Use it to create concise, credible website content.

Current Codex usage approach

Codex should be used as a careful implementation assistant and code tutor.

Preferred Codex settings for now:

Work locally
Plan Mode on
IDE context on
Default permissions
High intelligence
Standard speed
No full access

Codex should first inspect and explain the Hugo/Adritian structure before editing.

Codex should propose a section plan before changing site content.

Codex should make small, reviewable changes only after user approval.

What Codex should help with next

Next likely task:

Inspect the Hugo + Adritian project structure and identify which files control the main editable site content, configuration, navigation, homepage sections, blog/content pages, projects, contact area, static assets, and theme behavior.

Then propose a beginner-safe plan for customizing the Adritian demo into Hitesh Manani's personal website.

The plan should mark sections as:

keep
customize
repurpose
hide
remove later

No edits should be made during the first inspection/planning task.

Current next implementation goal

The next implementation goal is to replace Adritian demo content with a first personalized baseline.

Version 1 should focus on:

hero/homepage copy
about section
experience summary
skills/capabilities
selected projects
Cloud Resume Challenge project/case study placeholder
blog placeholder
contact links
resume download placeholder if appropriate
small personal layer if it fits naturally

Avoid for Version 1:

React
Next.js
Astro
CMS
chatbot
analytics
newsletter tooling
comments
multilingual complexity
advanced animations
heavy theme rewrites
Azure deployment
visitor counter backend
CI/CD


Then commit it:
git add notes/project-handoff.md
git commit -m "Add project handoff notes for Codex"
git push

Then verify:
git status
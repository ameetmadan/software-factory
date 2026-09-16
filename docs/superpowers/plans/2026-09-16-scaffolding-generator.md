# Project Scaffolding/Generator Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the `fullstack-app-template` GitHub template repo — bundling sub-projects 1+2's output (AGENTS.md conventions, guardrails, skills) via a git submodule into a real, working full-stack (React/TS/Vite + Node/Express/TS) project skeleton — and prove it works by generating a real project from it.

**Architecture:** Two-repo plan. This document lives in `software-factory` (per convention), but **every task below operates in a separate, already-created repo**: `ameetmadan/fullstack-app-template`, cloned locally at `/Users/ameetmadan/Workspace/fullstack-app-template`, on branch `feature/template-scaffold`. That repo already has `software-factory` added as a submodule at `.factory/` (pinned to sub-project 2's final commit `5cba2a4`), pushed to its `main`. Do not confuse this with the `software-factory` worktree this plan document lives in.

**Tech Stack:** React 18 + TypeScript + Vite + Vitest (frontend), Node + Express 4 + TypeScript + Vitest + Supertest (backend), git submodules, GitHub Actions.

**Spec:** `docs/superpowers/specs/2026-09-16-scaffolding-generator-design.md`

## Global Constraints

- **Repo:** every task's files are created in `/Users/ameetmadan/Workspace/fullstack-app-template` (the `fullstack-app-template` clone), on branch `feature/template-scaffold` — NOT in the `software-factory` worktree.
- Conventional commit types: `feat:`, `fix:`, `docs:`, `chore:`.
- TypeScript strict mode in both `frontend/` and `backend/` (`"strict": true`).
- Already-resolved action SHA pins to reuse verbatim (same actions, same versions already verified in `software-factory`'s own CI): `actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1`, `wagoid/commitlint-github-action@b948419dd99f3fd78a6548d48f94e3df7f6bf3ed # v6.2.1`, `gitleaks/gitleaks-action@e0c47f4f8be36e29cdc102c57e68cb5cbf0e8d1e # v3.0.0`.
- Skill files use YAML frontmatter with `name` and `description` fields.

---

### Task 1: `CLAUDE.md` and Cursor pointer

**Files:**

- Create: `CLAUDE.md`
- Create: `.cursor/rules/agents.mdc`

**Interfaces:**

- Consumes: `.factory/AGENTS.md` (already present via the submodule).
- Produces: nothing further in this plan consumes this — it's the Claude Code / Cursor entry point for anyone who clones the generated project.

- [ ] **Step 1: Write `CLAUDE.md`**

```markdown
# fullstack-app-template

@.factory/AGENTS.md
```

- [ ] **Step 2: Write `.cursor/rules/agents.mdc`**

```markdown
---
description: Project conventions (imports .factory/AGENTS.md)
alwaysApply: true
---

See @.factory/AGENTS.md for full project conventions: git workflow,
security, code quality, architecture, API design, testing, performance,
observability, and documentation standards. This file exists only so
Cursor loads those conventions automatically — do not duplicate content
here.
```

- [ ] **Step 3: Verify the import resolves**

Run: `cat /Users/ameetmadan/Workspace/fullstack-app-template/.factory/AGENTS.md | head -1`

Expected: `# Agent & Contributor Conventions` — confirms the submodule path `CLAUDE.md` points at actually has real content (not an empty/uninitialized submodule).

- [ ] **Step 4: Commit**

```bash
git add CLAUDE.md .cursor/rules/agents.mdc
git commit -m "docs: add CLAUDE.md and Cursor pointer importing .factory/AGENTS.md"
```

---

### Task 2: Copy `discovery` and `prioritize-features` skills verbatim

**Files:**

- Create: `.claude/skills/discovery/SKILL.md`
- Create: `.claude/skills/prioritize-features/SKILL.md`

**Interfaces:**

- Consumes: `.factory/.claude/skills/discovery/SKILL.md` and `.factory/.claude/skills/prioritize-features/SKILL.md` (already present via the submodule, already generic/self-contained per sub-project 2's own design).
- Produces: these two skills, usable by Claude Code once at `.claude/skills/` (Claude Code doesn't load skills from inside a submodule).

- [ ] **Step 1: Copy both skill files verbatim**

```bash
mkdir -p .claude/skills/discovery .claude/skills/prioritize-features
cp .factory/.claude/skills/discovery/SKILL.md .claude/skills/discovery/SKILL.md
cp .factory/.claude/skills/prioritize-features/SKILL.md .claude/skills/prioritize-features/SKILL.md
```

- [ ] **Step 2: Verify byte-for-byte match**

Run: `diff .factory/.claude/skills/discovery/SKILL.md .claude/skills/discovery/SKILL.md && diff .factory/.claude/skills/prioritize-features/SKILL.md .claude/skills/prioritize-features/SKILL.md && echo "MATCH"`

Expected: `MATCH` with no diff output above it.

- [ ] **Step 3: Commit**

```bash
git add .claude/skills/discovery/SKILL.md .claude/skills/prioritize-features/SKILL.md
git commit -m "feat: copy discovery and prioritize-features skills from software-factory"
```

---

### Task 3: Adapted `roadmap` skill (generic, no piece labels)

**Files:**

- Create: `.claude/skills/roadmap/SKILL.md`

**Interfaces:**

- Consumes: nothing from the submodule directly (this is a rewrite, not a copy) — but must stay consistent with software-factory's `roadmap` skill's underlying pattern (GitHub Issues as the persistence layer, `epic`/`task` labels, the same `gh issue create`/`comment`/`close` command shapes).
- Produces: the `roadmap` skill, referenced by Task 4's `plan-feature` skill.

- [ ] **Step 1: Write `.claude/skills/roadmap/SKILL.md`**

```markdown
---
name: roadmap
description: Create or update GitHub issues for this project's roadmap (epics) and concrete work (tasks). Use when starting new roadmap work, breaking an epic into tasks, or updating issue status.
---

# Roadmap

GitHub Issues are the persistence layer for this project's roadmap — not
chat history, not local todos. Use this skill any time roadmap state
needs to change.

## Creating an epic

One epic per major feature or subsystem. Check for an existing one before
creating a duplicate: `gh issue list --label epic --search "<name>"`.

```bash
gh issue create \
  --title "[Epic] <name>" \
  --label "epic" \
  --body "$(cat <<'EOF'
## Scope
<what's in / out for this epic>
EOF
)"
```

## Creating a task under an epic

```bash
gh issue create \
  --title "<concrete task>" \
  --label "task" \
  --body "Part of #<epic-issue-number>"
```

## Updating status

Comment on the issue rather than editing the body, so history is
preserved:

```bash
gh issue comment <number> --body "<status update>"
```

Close with `gh issue close <number> --comment "<why>"` once the task or
epic's deliverable is verified working, not just implemented.

## Listing current roadmap state

```bash
gh issue list --label epic --state all
gh issue list --label task --state open
```

## Labels

Only two labels: `epic`, `task`. Create them if they don't exist yet:

```bash
gh label create epic --color 5319e7 --description "Top-level roadmap item" --force
gh label create task --color 1d76db --description "Concrete unit of work under an epic" --force
```
```

- [ ] **Step 2: Commit**

```bash
git add .claude/skills/roadmap/SKILL.md
git commit -m "feat: add generic roadmap skill for GitHub Issues tracking"
```

---

### Task 4: `plan-feature` skill (adapted from software-factory's `new-subproject`)

**Files:**

- Create: `.claude/skills/plan-feature/SKILL.md`

**Interfaces:**

- Consumes: the `roadmap` skill (Task 3) by name.
- Produces: the `plan-feature` skill, the generic entry point for designing any new feature/subsystem in this project.

- [ ] **Step 1: Write `.claude/skills/plan-feature/SKILL.md`**

```markdown
---
name: plan-feature
description: Kick off the spec-to-plan cycle for a new feature or subsystem in this project. Use when starting design work on something non-trivial.
---

# Plan Feature

Any non-trivial new feature or subsystem gets its own spec → plan →
implementation cycle before code gets written.

## Steps

1. Find or create the feature's epic issue: `gh issue list --label epic
--search "<name>"`. If it doesn't exist yet, use the `roadmap` skill
   to create it first.
2. Design the feature: classify scope, ask clarifying questions, propose
   2-3 approaches, and present a design before writing any code. If the
   `superpowers` Claude Code plugin is installed, its `brainstorming`
   skill implements this well — invoke `superpowers:brainstorming`;
   otherwise run the same process manually.
3. When the design doc is written, save it to `docs/specs/` and commit
   it. Update the epic issue: `gh issue comment <epic-number> --body
"Design doc: docs/specs/<file>.md"`.
4. Turn the spec into a task-by-task implementation plan (file
   structure, bite-sized steps, testing per task). If the `superpowers`
   plugin is installed, its `writing-plans` skill implements this well
   — invoke `superpowers:writing-plans`; otherwise write the plan
   directly using the same structure.
5. As the plan produces concrete tasks, file each as a task issue linked
   to the epic via the `roadmap` skill.

## Constraints

- Don't skip straight to implementation for anything non-trivial —
  every feature goes through the same brainstorming → spec → plan
  cycle.
- Don't create a second epic for a feature that already has one; update
  the existing epic instead.
```

- [ ] **Step 2: Commit**

```bash
git add .claude/skills/plan-feature/SKILL.md
git commit -m "feat: add plan-feature skill for designing new features"
```

---

### Task 5: `frontend/` scaffold (React + TypeScript + Vite)

**Files:**

- Create: `frontend/package.json`
- Create: `frontend/tsconfig.json`
- Create: `frontend/vite.config.ts`
- Create: `frontend/index.html`
- Create: `frontend/src/main.tsx`
- Create: `frontend/src/App.tsx`
- Create: `frontend/src/App.test.tsx`
- Create: `frontend/src/atoms/README.md`
- Create: `frontend/src/molecules/README.md`
- Create: `frontend/src/organisms/README.md`
- Create: `frontend/src/templates/README.md`
- Create: `frontend/src/pages/README.md`

**Interfaces:**

- Consumes: nothing from other tasks.
- Produces: a working, buildable, testable frontend — Task 7's CI workflow runs `npm test` here.

- [ ] **Step 1: Write `frontend/package.json`**

```json
{
  "name": "frontend",
  "private": true,
  "version": "0.0.1",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc -b && vite build",
    "test": "vitest run"
  },
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1"
  },
  "devDependencies": {
    "@types/react": "^18.3.12",
    "@types/react-dom": "^18.3.1",
    "@vitejs/plugin-react": "^4.3.4",
    "typescript": "^5.7.2",
    "vite": "^6.0.5",
    "vitest": "^2.1.8"
  }
}
```

- [ ] **Step 2: Write `frontend/tsconfig.json`**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "useDefineForClassFields": true,
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"]
}
```

- [ ] **Step 3: Write `frontend/vite.config.ts`**

```typescript
/// <reference types="vitest/config" />
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
});
```

- [ ] **Step 4: Write `frontend/index.html`**

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Full-Stack App</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

- [ ] **Step 5: Write `frontend/src/main.tsx`**

```tsx
import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import App from "./App";

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
```

- [ ] **Step 6: Write `frontend/src/App.tsx`**

```tsx
function App() {
  return (
    <main>
      <h1>Full-Stack App</h1>
      <p>Edit src/App.tsx to get started.</p>
    </main>
  );
}

export default App;
```

- [ ] **Step 7: Write `frontend/src/App.test.tsx`**

```tsx
import { describe, expect, it } from "vitest";
import App from "./App";

describe("App", () => {
  it("is a function component", () => {
    expect(typeof App).toBe("function");
  });
});
```

- [ ] **Step 8: Write the five atomic-design stub READMEs**

`frontend/src/atoms/README.md`:

```markdown
# Atoms

Smallest reusable UI building blocks — buttons, inputs, labels. No
business logic, no knowledge of where they're used.
```

`frontend/src/molecules/README.md`:

```markdown
# Molecules

Small groups of atoms working together — a labeled input, a button with
an icon.
```

`frontend/src/organisms/README.md`:

```markdown
# Organisms

Larger, distinct sections of an interface composed of molecules and
atoms — a header, a form, a card list.
```

`frontend/src/templates/README.md`:

```markdown
# Templates

Page-level layouts that arrange organisms, without real content — the
skeleton a page fills in.
```

`frontend/src/pages/README.md`:

```markdown
# Pages

Templates filled in with real content and wired to real data/routes.
```

- [ ] **Step 9: Install dependencies and verify build + test**

Run: `npm install && npm run build && npm test`

Expected: `npm install` succeeds, `npm run build` succeeds (produces a
`dist/` directory), `npm test` reports 1 passing test.

- [ ] **Step 10: Commit**

```bash
git add frontend/
git commit -m "feat: scaffold frontend (React + TypeScript + Vite)"
```

---

### Task 6: `backend/` scaffold (Node + Express + TypeScript)

**Files:**

- Create: `backend/package.json`
- Create: `backend/tsconfig.json`
- Create: `backend/src/index.ts`
- Create: `backend/src/infrastructure/health.ts`
- Create: `backend/src/infrastructure/health.test.ts`
- Create: `backend/src/domain/README.md`
- Create: `backend/src/application/README.md`

**Interfaces:**

- Consumes: nothing from other tasks.
- Produces: a working, buildable, testable backend with a `/health` endpoint — Task 7's CI workflow runs `npm test` here.

- [ ] **Step 1: Write `backend/package.json`**

```json
{
  "name": "backend",
  "private": true,
  "version": "0.0.1",
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc -p tsconfig.json",
    "start": "node dist/index.js",
    "test": "vitest run"
  },
  "dependencies": {
    "express": "^4.21.2"
  },
  "devDependencies": {
    "@types/express": "^5.0.0",
    "@types/node": "^22.10.2",
    "@types/supertest": "^6.0.2",
    "supertest": "^7.0.0",
    "tsx": "^4.19.2",
    "typescript": "^5.7.2",
    "vitest": "^2.1.8"
  }
}
```

- [ ] **Step 2: Write `backend/tsconfig.json`**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "outDir": "dist",
    "rootDir": "src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true
  },
  "include": ["src"]
}
```

- [ ] **Step 3: Write `backend/src/infrastructure/health.ts`**

```typescript
import { Router } from "express";

export const healthRouter = Router();

healthRouter.get("/health", (_req, res) => {
  res.status(200).json({ status: "ok" });
});
```

- [ ] **Step 4: Write `backend/src/index.ts`**

```typescript
import express from "express";
import { healthRouter } from "./infrastructure/health.js";

const app = express();
const port = process.env.PORT ?? 3000;

app.use(healthRouter);

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});

export { app };
```

- [ ] **Step 5: Write `backend/src/infrastructure/health.test.ts`**

```typescript
import { describe, expect, it } from "vitest";
import request from "supertest";
import express from "express";
import { healthRouter } from "./health.js";

describe("GET /health", () => {
  it("returns 200 with status ok", async () => {
    const app = express();
    app.use(healthRouter);
    const res = await request(app).get("/health");
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ status: "ok" });
  });
});
```

- [ ] **Step 6: Write the two hexagonal-architecture stub READMEs**

`backend/src/domain/README.md`:

```markdown
# Domain

Framework-independent business logic and entities. No imports from
`express`, no knowledge of HTTP, no I/O.
```

`backend/src/application/README.md`:

```markdown
# Application

Use cases and orchestration — coordinates domain logic, calls out to
infrastructure through interfaces it defines, doesn't implement I/O
itself.
```

- [ ] **Step 7: Install dependencies and verify build + test**

Run: `npm install && npm run build && npm test`

Expected: `npm install` succeeds, `npm run build` succeeds (produces a
`dist/` directory), `npm test` reports 1 passing test.

- [ ] **Step 8: Commit**

```bash
git add backend/
git commit -m "feat: scaffold backend (Node + Express + TypeScript) with a health endpoint"
```

---

### Task 7: Guardrails and CI workflow

**Files:**

- Create: `.pre-commit-config.yaml` (copied from `.factory/`)
- Create: `commitlint.config.cjs` (copied from `.factory/`)
- Create: `.gitleaksignore` (copied from `.factory/`)
- Create: `.github/workflows/ci.yml`

**Interfaces:**

- Consumes: `.factory/.pre-commit-config.yaml`, `.factory/commitlint.config.cjs`, `.factory/.gitleaksignore` (already self-contained/generic, no adaptation needed); the already-resolved action SHAs from Global Constraints; `frontend/`, `backend/` (Tasks 5/6) as the directories CI's `test` job runs against.
- Produces: nothing further in this plan consumes this — it's the final guardrail layer.

- [ ] **Step 1: Copy the three guardrail config files verbatim**

```bash
cp .factory/.pre-commit-config.yaml .pre-commit-config.yaml
cp .factory/commitlint.config.cjs commitlint.config.cjs
cp .factory/.gitleaksignore .gitleaksignore
```

- [ ] **Step 2: Verify byte-for-byte match**

Run: `diff .factory/.pre-commit-config.yaml .pre-commit-config.yaml && diff .factory/commitlint.config.cjs commitlint.config.cjs && diff .factory/.gitleaksignore .gitleaksignore && echo "MATCH"`

Expected: `MATCH` with no diff output above it.

- [ ] **Step 3: Install pre-commit locally and verify it runs**

Run: `pre-commit install --hook-type pre-commit --hook-type commit-msg && pre-commit run --all-files`

Expected: the secret-detection hook passes on the files committed so far (no real secrets in this scaffold).

- [ ] **Step 4: Resolve the current SHA for `actions/setup-node`**

Run: `git ls-remote https://github.com/actions/setup-node refs/tags/v4*`

Pick the latest matching `v4.x.y` tag; if it's an annotated tag, use the `^{}` dereferenced commit SHA (not the tag object's own SHA) — the same method already used for the three other actions in Global Constraints.

- [ ] **Step 5: Write `.github/workflows/ci.yml`**

Using the SHA resolved in Step 4 in place of `<SETUP_NODE_SHA>` and `<SETUP_NODE_VERSION>` below:

```yaml
name: CI

on:
  pull_request:
  push:
    branches: [main]

permissions:
  contents: read

jobs:
  commitlint:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: read
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
        with:
          fetch-depth: 0
      - uses: wagoid/commitlint-github-action@b948419dd99f3fd78a6548d48f94e3df7f6bf3ed # v6.2.1

  secret-scan:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
        with:
          fetch-depth: 0
      - uses: gitleaks/gitleaks-action@e0c47f4f8be36e29cdc102c57e68cb5cbf0e8d1e # v3.0.0
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
      - uses: actions/setup-node@<SETUP_NODE_SHA> # <SETUP_NODE_VERSION>
        with:
          node-version: "20"
      - name: Install and test frontend
        working-directory: frontend
        run: |
          npm install
          npm test
      - name: Install and test backend
        working-directory: backend
        run: |
          npm install
          npm test
```

- [ ] **Step 6: Validate the workflow YAML with a real parser**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml')); print('valid YAML')"` (or an equivalent real parser available in your environment — not grep/manual inspection, per the lesson from software-factory's own Task 5 review).

Expected: `valid YAML`.

- [ ] **Step 7: Commit**

```bash
git add .pre-commit-config.yaml commitlint.config.cjs .gitleaksignore .github/workflows/ci.yml
git commit -m "feat: add guardrails and CI workflow (commitlint, secret-scan, frontend+backend tests)"
```

---

### Task 8: `README.md`

**Files:**

- Create: `README.md`

**Interfaces:**

- Consumes: everything from Tasks 1–7 (submodule, skills, frontend, backend, guardrails).
- Produces: nothing further consumes this — it's the human entry point for anyone who generates a project from this template.

- [ ] **Step 1: Write `README.md`**

```markdown
# fullstack-app-template

A full-stack (React + TypeScript + Vite frontend, Node + Express +
TypeScript backend) project template with AI tooling and guardrails
built in — generated from
[software-factory](https://github.com/ameetmadan/software-factory).

## Getting started

**Clone with submodules** — a plain `git clone` leaves `.factory/`
empty and `CLAUDE.md`'s import broken:

```bash
git clone --recurse-submodules <your-new-repo-url>
```

Already cloned without `--recurse-submodules`? Run:

```bash
git submodule update --init --recursive
```

Prerequisites: Node.js 20+, Go and a Node.js toolchain (pre-commit
builds the gitleaks and commitlint hooks from source), and the `gh` CLI
installed and authenticated. If `pip install pre-commit` fails with an
"externally-managed-environment" error, use `pipx install pre-commit`
or `brew install pre-commit` instead.

```bash
# Install and enable local guardrails
pip install pre-commit
pre-commit install --hook-type pre-commit --hook-type commit-msg

# Frontend
cd frontend && npm install && npm run dev

# Backend (in another terminal)
cd backend && npm install && npm run dev
```

## Structure

```
.
├── .factory/          # software-factory submodule — AGENTS.md, source of truth for conventions
├── frontend/           # React + TypeScript + Vite, atomic-design structure
├── backend/             # Node + Express + TypeScript, hexagonal-architecture structure
└── .github/workflows/  # CI: commitlint, secret-scan, frontend+backend tests
```

## AI tooling

Conventions live in [`AGENTS.md`](./.factory/AGENTS.md) (imported by
`CLAUDE.md` for Claude Code, natively by Cursor). Skills:

- `roadmap` — create/update GitHub issues for this project's roadmap.
- `plan-feature` — kick off the spec → plan cycle for a new feature.
- `discovery` — capture requirements for a new project idea.
- `prioritize-features` — RICE-score a feature backlog and file it as
  GitHub issues.

## Guardrails

Every commit is checked locally (`pre-commit`) and again in CI:
commit messages must follow [Conventional
Commits](https://www.conventionalcommits.org/), no secrets/API keys
(scanned via [gitleaks](https://github.com/gitleaks/gitleaks)), and
both `frontend/` and `backend/` tests run in CI.
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: write README covering setup, structure, AI tooling, and guardrails"
```

---

### Task 9: Validation — generate a real project from the template

**Files:**

- None created in `fullstack-app-template` — this task pushes the branch, opens/merges it, then exercises the template externally.

**Interfaces:**

- Consumes: everything from Tasks 1–8.
- Produces: `ameetmadan/fullstack-app-demo`, a real generated project, kept as a working example.

- [ ] **Step 1: Push the branch**

```bash
git push -u origin feature/template-scaffold
```

- [ ] **Step 2: Verify CI is green on this branch**

Run: `gh pr create --title "feat: scaffold full-stack template" --body "Frontend, backend, skills, guardrails, and CI for the template repo." --base main --head feature/template-scaffold` then watch the resulting CI run to completion (`gh run watch <run-id> --exit-status`, finding the run via `gh run list --branch feature/template-scaffold --limit 1`).

Expected: all three jobs (`commitlint`, `secret-scan`, `test`) pass.

- [ ] **Step 3: Generate a real project from the template**

```bash
gh repo create ameetmadan/fullstack-app-demo --template ameetmadan/fullstack-app-template --public
```

Note: `gh repo create --template` generates from the template repo's
default branch (`main`), which at this point doesn't yet have Tasks
1–8's content merged. Merge `feature/template-scaffold` into `main` in
`ameetmadan/fullstack-app-template` first (via the PR from Step 2, or a
direct merge if you're the only contributor), then run this step.

- [ ] **Step 4: Clone the generated project and verify the submodule**

```bash
git clone --recurse-submodules https://github.com/ameetmadan/fullstack-app-demo.git /tmp/fullstack-app-demo-check
cat /tmp/fullstack-app-demo-check/.factory/AGENTS.md | head -1
```

Expected: `# Agent & Contributor Conventions` — confirms the submodule
resolved correctly in a project generated via "Use this template", not
just in the original clone.

- [ ] **Step 5: Verify both apps install and build in the generated project**

```bash
(cd /tmp/fullstack-app-demo-check/frontend && npm install && npm run build && npm test)
(cd /tmp/fullstack-app-demo-check/backend && npm install && npm run build && npm test)
```

Expected: both succeed — install, build, and 1 passing test each.

- [ ] **Step 6: Confirm the generated project's own CI is green**

Run: `gh run list --repo ameetmadan/fullstack-app-demo --limit 1` (a push to a freshly-generated repo's default branch triggers the inherited CI workflow) then watch it to completion.

Expected: all three jobs pass, proving the template's CI configuration works standalone in a generated project, not just in the template repo itself.

- [ ] **Step 7: Clean up the local check clone**

```bash
rm -rf /tmp/fullstack-app-demo-check
```

`ameetmadan/fullstack-app-demo` itself stays on GitHub as a visible,
working example (per the spec's Validation section) — do not delete it.

# CI Pipeline Templates Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a GitHub reusable workflow (`workflow_call`) hosted in `software-factory` providing lint+test+build for a Node project, and prove it works by refactoring `fullstack-app-template`'s own CI to call it — closing a known gap (no ESLint config) along the way.

**Architecture:** Two-repo plan, same pattern as sub-project 3. Tasks 1-2 operate in `software-factory` (the worktree this plan document lives in). Tasks 3-6 operate in a **separate, already-created** clone at `/Users/ameetmadan/Workspace/fullstack-app-template`, on branch `feature/ci-reusable-workflow` (already checked out, synced to the merged `main`). Do not confuse the two.

**Tech Stack:** GitHub Actions reusable workflows, ESLint 9 (flat config) + typescript-eslint, `eslint-plugin-react-hooks`/`eslint-plugin-react-refresh` for the frontend.

**Spec:** `docs/superpowers/specs/2026-09-16-ci-pipeline-templates-design.md`

## Global Constraints

- Already-resolved action SHA pins to reuse verbatim: `actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1`, `actions/setup-node@820762786026740c76f36085b0efc47a31fe5020 # v7.0.0`.
- Conventional commit types: `feat:`, `fix:`, `docs:`, `chore:`.
- The `commitlint`/`secret-scan` jobs in `fullstack-app-template`'s `.github/workflows/ci.yml` are NOT touched by this plan.
- Skill/workflow files that declare frontmatter or `on:` triggers must be internally consistent — `ci-node.yml` triggers ONLY on `workflow_call`, never standalone.

---

### Task 1: `ci-node.yml` reusable workflow

**Files:**

- Create: `.github/workflows/ci-node.yml` (in `software-factory`, this worktree)

**Interfaces:**

- Consumes: nothing (first task).
- Produces: the reusable workflow itself, called by `working-directory` input. Its commit SHA (resolved after committing) is consumed by Task 5, in the `fullstack-app-template` repo.

- [ ] **Step 1: Write `.github/workflows/ci-node.yml`**

```yaml
name: CI Node Pipeline

on:
  workflow_call:
    inputs:
      working-directory:
        required: true
        type: string
      node-version:
        required: false
        type: string
        default: "20"

permissions:
  contents: read

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
      - uses: actions/setup-node@820762786026740c76f36085b0efc47a31fe5020 # v7.0.0
        with:
          node-version: ${{ inputs.node-version }}
      - working-directory: ${{ inputs.working-directory }}
        run: npm ci
      - working-directory: ${{ inputs.working-directory }}
        run: npm run lint

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
      - uses: actions/setup-node@820762786026740c76f36085b0efc47a31fe5020 # v7.0.0
        with:
          node-version: ${{ inputs.node-version }}
      - working-directory: ${{ inputs.working-directory }}
        run: npm ci
      - working-directory: ${{ inputs.working-directory }}
        run: npm test

  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
      - uses: actions/setup-node@820762786026740c76f36085b0efc47a31fe5020 # v7.0.0
        with:
          node-version: ${{ inputs.node-version }}
      - working-directory: ${{ inputs.working-directory }}
        run: npm ci
      - working-directory: ${{ inputs.working-directory }}
        run: npm run build
```

- [ ] **Step 2: Validate the workflow YAML with a real parser**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci-node.yml')); print('valid YAML')"`

Expected: `valid YAML`.

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/ci-node.yml
git commit -m "feat: add ci-node reusable workflow (lint, test, build)"
```

- [ ] **Step 4: Record the commit SHA for later tasks**

Run: `git rev-parse HEAD`

Write down the full 40-character SHA this prints — Task 5 (in the
`fullstack-app-template` repo) needs it to pin the `uses:` reference.

---

### Task 2: `AGENTS.md` update

**Files:**

- Modify: `AGENTS.md` (in `software-factory`, this worktree — insert after the "Starting a new project idea" section, before "Git workflow")

**Interfaces:**

- Consumes: `.github/workflows/ci-node.yml` (Task 1) by name/path.
- Produces: nothing further in this plan consumes this — it's the discoverability entry point.

- [ ] **Step 1: Insert a new section into `AGENTS.md`**

Find this existing text (the end of the "Starting a new project idea"
section, added in sub-project 2):

```markdown
- Both skills fill in templates from `templates/discovery/` (also home to
  an `adr.md` template for recording architectural decisions, per the
  Documentation section below).

## Git workflow
```

Replace it with (inserting a new section between the two):

```markdown
- Both skills fill in templates from `templates/discovery/` (also home to
  an `adr.md` template for recording architectural decisions, per the
  Documentation section below).

## Reusable CI pipeline

`.github/workflows/ci-node.yml` is a GitHub reusable workflow
(`workflow_call`) providing lint+test+build for a Node project — call
it by reference instead of hand-rolling test/lint/build steps again:

```yaml
frontend-ci:
  uses: ameetmadan/software-factory/.github/workflows/ci-node.yml@<commit-sha>
  with:
    working-directory: frontend
```

Pin `@<commit-sha>` to a specific commit (not a branch) for supply-chain
safety, matching the SHA-pinning convention used throughout this repo's
own CI. `fullstack-app-template`'s `ci.yml` is the reference consumer.

## Git workflow
```

- [ ] **Step 2: Commit**

```bash
git add AGENTS.md
git commit -m "docs: document the ci-node reusable workflow in AGENTS.md"
```

---

### Task 3: ESLint for `frontend/`

**Files:**

- Create: `frontend/eslint.config.js` (in the `fullstack-app-template` clone at `/Users/ameetmadan/Workspace/fullstack-app-template`, branch `feature/ci-reusable-workflow`)
- Modify: `frontend/package.json` (add `eslint`/related devDependencies and a `"lint"` script)

**Interfaces:**

- Consumes: nothing from other tasks.
- Produces: a working `npm run lint` in `frontend/`, consumed by Task 1's reusable workflow once Task 5 wires it in.

- [ ] **Step 1: Add ESLint devDependencies to `frontend/package.json`**

Add these entries to the existing `devDependencies` object (keep all
existing entries unchanged):

```json
    "@eslint/js": "^9.17.0",
    "eslint": "^9.17.0",
    "eslint-plugin-react-hooks": "^5.1.0",
    "eslint-plugin-react-refresh": "^0.4.16",
    "globals": "^15.14.0",
    "typescript-eslint": "^8.18.0"
```

Add this entry to the existing `scripts` object:

```json
    "lint": "eslint ."
```

- [ ] **Step 2: Write `frontend/eslint.config.js`**

```javascript
import js from "@eslint/js";
import globals from "globals";
import reactHooks from "eslint-plugin-react-hooks";
import reactRefresh from "eslint-plugin-react-refresh";
import tseslint from "typescript-eslint";

export default tseslint.config(
  { ignores: ["dist"] },
  {
    extends: [js.configs.recommended, ...tseslint.configs.recommended],
    files: ["**/*.{ts,tsx}"],
    languageOptions: {
      ecmaVersion: 2022,
      globals: globals.browser,
    },
    plugins: {
      "react-hooks": reactHooks,
      "react-refresh": reactRefresh,
    },
    rules: {
      ...reactHooks.configs.recommended.rules,
      "react-refresh/only-export-components": [
        "warn",
        { allowConstantExport: true },
      ],
    },
  },
);
```

- [ ] **Step 3: Install and run lint**

Run: `npm install && npm run lint`

Expected: `npm install` succeeds. `npm run lint` exits 0 with no errors.
If it surfaces real violations in the existing scaffolded code (`App.tsx`,
`main.tsx`, `App.test.tsx`), fix them directly — don't disable the rule
that caught them, unless the rule is clearly inappropriate for this
codebase (explain why in your report if so).

- [ ] **Step 4: Confirm build and test still pass**

Run: `npm run build && npm test`

Expected: both still succeed, unaffected by the lint config addition.

- [ ] **Step 5: Commit**

```bash
git add frontend/package.json frontend/package-lock.json frontend/eslint.config.js
git commit -m "feat: add ESLint config and lint script to frontend"
```

---

### Task 4: ESLint for `backend/`

**Files:**

- Create: `backend/eslint.config.js` (in the `fullstack-app-template` clone)
- Modify: `backend/package.json` (add `eslint`/related devDependencies and a `"lint"` script)

**Interfaces:**

- Consumes: nothing from other tasks.
- Produces: a working `npm run lint` in `backend/`, consumed by Task 1's reusable workflow once Task 5 wires it in.

- [ ] **Step 1: Add ESLint devDependencies to `backend/package.json`**

Add these entries to the existing `devDependencies` object (keep all
existing entries unchanged):

```json
    "@eslint/js": "^9.17.0",
    "eslint": "^9.17.0",
    "globals": "^15.14.0",
    "typescript-eslint": "^8.18.0"
```

Add this entry to the existing `scripts` object:

```json
    "lint": "eslint ."
```

- [ ] **Step 2: Write `backend/eslint.config.js`**

```javascript
import js from "@eslint/js";
import globals from "globals";
import tseslint from "typescript-eslint";

export default tseslint.config(
  { ignores: ["dist"] },
  {
    extends: [js.configs.recommended, ...tseslint.configs.recommended],
    files: ["**/*.ts"],
    languageOptions: {
      ecmaVersion: 2022,
      globals: globals.node,
    },
  },
);
```

- [ ] **Step 3: Install and run lint**

Run: `npm install && npm run lint`

Expected: `npm install` succeeds. `npm run lint` exits 0 with no errors.
If it surfaces real violations in the existing scaffolded code
(`index.ts`, `health.ts`, `health.test.ts`), fix them directly — don't
disable the rule that caught them unless clearly inappropriate
(explain why in your report if so).

- [ ] **Step 4: Confirm build and test still pass**

Run: `npm run build && npm test`

Expected: both still succeed, unaffected by the lint config addition.

- [ ] **Step 5: Commit**

```bash
git add backend/package.json backend/package-lock.json backend/eslint.config.js
git commit -m "feat: add ESLint config and lint script to backend"
```

---

### Task 5: Refactor `ci.yml` to call the reusable workflow

**Files:**

- Modify: `.github/workflows/ci.yml` (in the `fullstack-app-template` clone)

**Interfaces:**

- Consumes: `software-factory`'s `.github/workflows/ci-node.yml` (Task 1) by its resolved commit SHA; `frontend`/`backend`'s `npm run lint` (Tasks 3/4).
- Produces: nothing further in this plan consumes this.

- [ ] **Step 1: Read the current `test` job**

The current `.github/workflows/ci.yml` has a `test` job that checks out,
sets up Node, then runs `npm ci && npm run build && npm test` in both
`frontend` and `backend` via two `run:` steps. This task replaces that
entire job with two jobs that call the reusable workflow instead.

- [ ] **Step 2: Replace the `test` job**

Remove the existing `test:` job entirely (checkout through the two
`working-directory` run steps), and add these two jobs in its place —
substituting the exact 40-character SHA you recorded in Task 1, Step 4,
for `<CI_NODE_SHA>` below:

```yaml
frontend-ci:
  uses: ameetmadan/software-factory/.github/workflows/ci-node.yml@<CI_NODE_SHA>
  with:
    working-directory: frontend

backend-ci:
  uses: ameetmadan/software-factory/.github/workflows/ci-node.yml@<CI_NODE_SHA>
  with:
    working-directory: backend
```

Leave the `commitlint` and `secret-scan` jobs completely untouched.

- [ ] **Step 3: Validate the workflow YAML with a real parser**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml')); print('valid YAML')"`

Expected: `valid YAML`.

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "feat: call the ci-node reusable workflow for frontend/backend CI"
```

---

### Task 6: Validation — push and confirm CI is green through the reusable workflow

**Files:**

- None created — this task pushes both branches and verifies live CI.

**Interfaces:**

- Consumes: everything from Tasks 1–5.
- Produces: a real, green CI run in `fullstack-app-template` proving the reusable workflow actually works cross-repo.

- [ ] **Step 1: Push `software-factory`'s branch**

Run (from `/Users/ameetmadan/Workspace/software-factory/.claude/worktrees/feature+ci-pipeline-templates`): `git push -u origin feature/ci-pipeline-templates`

- [ ] **Step 2: Push `fullstack-app-template`'s branch**

Run (from `/Users/ameetmadan/Workspace/fullstack-app-template`): `git push -u origin feature/ci-reusable-workflow`

- [ ] **Step 3: Open a PR in `fullstack-app-template` and watch CI**

```bash
gh pr create --repo ameetmadan/fullstack-app-template --base main --head feature/ci-reusable-workflow --title "feat: use ci-node reusable workflow for frontend/backend CI" --body "Refactors CI to call software-factory's new ci-node.yml reusable workflow instead of hand-rolling test/build steps; adds ESLint to both apps, closing a gap from sub-project 3's final review."
```

Then find and watch the resulting run: `gh run list --repo ameetmadan/fullstack-app-template --branch feature/ci-reusable-workflow --limit 1`, then `gh run watch <run-id> --repo ameetmadan/fullstack-app-template --exit-status`.

- [ ] **Step 4: Verify all jobs pass**

Expected: 6 jobs total — `commitlint`, `secret-scan` (unchanged), and
`frontend-ci`/`backend-ci` each expanding into `lint`, `test`, `build`
sub-jobs (6 jobs from the reusable workflow, 2 direct) — all green.
This is the real proof the reusable workflow resolves and runs
correctly when called from a different repository.

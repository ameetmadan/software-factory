# CI Pipeline Templates — Design

## Context

`software-factory` is built as six independent sub-projects (see
`AGENTS.md`). Sub-project 1 (AI pipeline & guardrails) shipped the
commit/secret guardrails baseline (commitlint, gitleaks) that every
project gets. Sub-project 3 (scaffolding/generator) shipped
`fullstack-app-template`, whose CI hand-rolls its own test/build steps
for `frontend/` and `backend/` directly in `.github/workflows/ci.yml`.
This document covers sub-project 4, per epic #4: **CI pipeline
templates** — reusable test/lint/build pipelines, layered on top of
sub-project 1's baseline guardrails, so that logic doesn't need to be
hand-rolled and duplicated in every project again.

## Goals

- Ship one real, working GitHub Actions **reusable workflow**
  (`workflow_call`) hosted in `software-factory` that provides
  lint+test+build for a Node project — GitHub's native mechanism for
  this kind of reuse, chosen over copy-paste templates so updates
  propagate by bumping a version reference instead of re-copying files.
- Prove it actually works by refactoring `fullstack-app-template`'s own
  CI to call it (once for `frontend/`, once for `backend/`), replacing
  its hand-rolled test job — not just building an unused template.
- Close a known gap from sub-project 3's final review: neither
  `frontend/` nor `backend/` had any lint configuration, despite
  `AGENTS.md` telling agents to "follow the project's ESLint config."
- Leave sub-project 1's guardrails (commitlint, secret-scan) untouched
  — this sub-project only adds the test/lint/build layer the epic
  describes as sitting on top of them.

## Non-goals

- No Python/Go/other-language pipelines yet — Node only, matching the
  one stack that's actually been built and validated so far
  (sub-project 3). Broader coverage is a later addition once a project
  actually needs a different stack.
- No changes to the commitlint/secret-scan jobs or `.pre-commit-config.yaml`
  — those stay exactly as sub-project 1 shipped them.
- No copy-paste CI templates (e.g. under `templates/ci/`) — the reusable
  workflow _is_ the template; a project "uses" it by reference, not by
  copying a file.

## Design

### 1. The reusable workflow

`.github/workflows/ci-node.yml` in `software-factory`, triggered only by
`workflow_call` (never runs on its own):

- **Inputs:** `working-directory` (string, required — which directory to
  run in, e.g. `frontend` or `backend`), `node-version` (string,
  optional, default `"20"`).
- **Jobs:** `lint`, `test`, `build` — each does its own checkout +
  `actions/setup-node` + `npm ci` (using the already-resolved,
  SHA-pinned `actions/checkout@v7.0.1` and `actions/setup-node@v7.0.0`
  from sub-project 3), then runs `npm run lint` / `npm test` / `npm run
build` respectively inside `inputs.working-directory`.
- `permissions: contents: read` at the workflow level (matching the
  pattern established in sub-projects 1 and 3).

### 2. ESLint added to `fullstack-app-template`

- `frontend/`: flat-config `eslint.config.js` using `@eslint/js`,
  `typescript-eslint`, `eslint-plugin-react-hooks`,
  `eslint-plugin-react-refresh` (the standard Vite+React+TS lint stack)
  — matching what `npm create vite` itself scaffolds for this exact
  stack combination, so it's a well-trodden, unsurprising setup rather
  than a bespoke one. A `"lint": "eslint ."` script added to
  `package.json`.
- `backend/`: flat-config `eslint.config.js` using `@eslint/js` +
  `typescript-eslint` only (no React-specific plugins). Same
  `"lint": "eslint ."` script added.
- Both configs run clean against the existing scaffolded code (the lint
  job must actually pass, not just exist) — any lint violations the new
  config surfaces in existing code get fixed as part of this sub-project,
  not silently ignored.

### 3. `fullstack-app-template`'s CI refactored to call the reusable workflow

`fullstack-app-template`'s `.github/workflows/ci.yml` `test` job
(currently one hand-rolled job installing/building/testing both
`frontend/` and `backend/` in sequence) is replaced with two jobs that
each call the new reusable workflow:

```yaml
frontend-ci:
  uses: ameetmadan/software-factory/.github/workflows/ci-node.yml@<PINNED_SHA>
  with:
    working-directory: frontend

backend-ci:
  uses: ameetmadan/software-factory/.github/workflows/ci-node.yml@<PINNED_SHA>
  with:
    working-directory: backend
```

`<PINNED_SHA>` is the commit in `software-factory` that adds
`ci-node.yml`, resolved during implementation once that commit exists —
pinned to the current stacked branch tip for now (the same pattern
already used for the `.factory` submodule pin), with a note to re-pin
once `software-factory`'s stacked PRs merge to `main`. The
`commitlint`/`secret-scan` jobs in `fullstack-app-template`'s `ci.yml`
are untouched.

### 4. `AGENTS.md` update

A one-line addition to the existing "Starting a new project idea"
section (or a new short section, whichever reads more naturally once
drafted) pointing at `.github/workflows/ci-node.yml` as the reusable
Node CI pipeline, so a future project — or sub-project 5/6 — knows it
exists instead of hand-rolling test/lint/build again.

### Validation

The real test is that `fullstack-app-template`'s CI is still green
after the refactor, now running through the reusable workflow instead
of a hand-rolled job:

1. Add ESLint configs, confirm `npm run lint` passes locally in both
   `frontend/` and `backend/` (fixing any real violations surfaced).
2. Commit and push `ci-node.yml` to `software-factory`, resolve its
   commit SHA.
3. Refactor `fullstack-app-template`'s `ci.yml` to call it with that
   SHA, push, and confirm the resulting PR's CI is green — six jobs
   total now (`commitlint`, `secret-scan`, `frontend-ci` → lint/test/build,
   `backend-ci` → lint/test/build), all passing.
4. Confirm `fullstack-app-demo` (the permanent worked example from
   sub-project 3) is unaffected by this change until it's manually
   regenerated or re-synced — noted as out of scope for this
   sub-project (it inherited the old `ci.yml` at generation time; no
   live sync mechanism exists, by design, from sub-project 3).

## Open questions

None outstanding — all decisions above were confirmed during
brainstorming, including the explicit choice of GitHub reusable
workflows over copy-paste templates, and the SHA-pinning-to-current-tip
pattern reused from sub-project 3's submodule design.

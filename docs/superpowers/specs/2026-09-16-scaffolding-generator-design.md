# Project Scaffolding/Generator — Design

## Context

`software-factory` is built as six independent sub-projects (see
`AGENTS.md`). Sub-project 1 (AI pipeline & guardrails, PR #8) shipped
the conventions layer, roadmap tracking, and guardrail automation.
Sub-project 2 (discovery/planning kit, PR #13, stacked on #8) shipped
generic requirements-capture and RICE-prioritization skills. This
document covers sub-project 3, per epic #3: **project
scaffolding/generator** — a GitHub template repo that bundles
everything from sub-projects 1 and 2 into a real, working full-stack
project skeleton, so a new project idea gets working code, AI tooling,
and guardrails from the first commit.

A CLI generator (interactively prompting for project name/options) is
explicitly out of scope per the epic — this sub-project ships the
template repo itself; the generator is a later addition.

## Goals

- Ship one full-stack (frontend + backend) template repo, marked as a
  GitHub template (`is_template: true`), so "Use this template" produces
  a working project skeleton in one click.
- Bundle sub-projects 1 and 2's output (AGENTS.md conventions,
  guardrails, and skills) into every generated project — no starting
  from a blank prompt.
- Keep the template repo connected to `software-factory` at the git
  level via a submodule, so conventions text has one source of truth
  and updates can be pulled deliberately later, accepting the
  clone/update friction that entails (a decision made explicitly, with
  the trade-off understood, during brainstorming).
- Prove the whole chain works: generate a real project from the
  template and confirm it builds, passes guardrails, and runs CI green.

## Non-goals

- No interactive CLI generator — that's a later addition per the epic.
- No additional stacks/frameworks beyond React+TypeScript+Vite
  (frontend) and Node+Express+TypeScript (backend) — one full-stack
  template, not a library of templates.
- No automatic/live sync between `software-factory` and the template
  repo — the submodule pin is updated manually when needed, not on
  every `software-factory` change.

## Design

### 1. Repository & connection

- New GitHub repo: `ameetmadan/fullstack-app-template`, created via
  `gh repo create`, marked `is_template: true` via the GitHub API
  (`gh api repos/ameetmadan/fullstack-app-template -X PATCH -f
is_template=true`).
- `software-factory` is added as a git submodule at `.factory/`, pinned
  to the current tip of `software-factory`'s stacked branch (which
  carries both sub-project 1 and 2's commits, since PRs #8/#13 aren't
  merged to `main` yet). **Note for implementation:** once #8 and #13
  merge, the submodule pin should be updated to track `main` — this
  sub-project pins to the current feature-branch tip so it can be built
  and validated now, without waiting on those merges.
- `CLAUDE.md` at the template repo's root becomes `@.factory/AGENTS.md`
  (not `@AGENTS.md` — there's no root-level `AGENTS.md` file, since the
  conventions text lives once, inside the submodule).
  `.cursor/rules/agents.mdc` is updated the same way.
- The template's `README.md` leads with a prominent "clone with
  `git clone --recurse-submodules`" callout, since a plain clone leaves
  `.factory/` empty and `CLAUDE.md`'s import broken.

### 2. Skills bundled (flat copies at `.claude/skills/`)

Claude Code loads project skills from `.claude/skills/` at the repo
root, not from inside a submodule — so skills are copied as real local
files, not referenced through `.factory/`:

- **`discovery`**, **`prioritize-features`** — copied verbatim from
  `software-factory` (already generic, built that way in sub-project 2:
  no `software-factory`-specific labels or roadmap references).
- **`roadmap`** — adapted: drop `software-factory`'s six piece labels
  and its hardcoded six-epic list. Keep the generic pattern (GitHub
  Issues as the roadmap persistence layer, `epic`/`task` labels, the
  same `gh issue create`/`comment`/`close` conventions) but scoped to
  whatever epics/tasks the new project actually has — no piece-label
  bootstrap script needed, since there's no fixed six-piece structure
  to bootstrap labels for.
- **`new-subproject` → `plan-feature`** (renamed and adapted): instead
  of "kick off the next of software-factory's six pieces," this
  becomes "kick off the brainstorm → spec → plan cycle for any new
  feature or subsystem in _this_ project." Same underlying process
  (find/create an epic via `roadmap`, brainstorm, write a spec, write a
  plan, file task issues) with the software-factory-specific framing
  removed.

### 3. Application scaffolding

`frontend/` — React + TypeScript + Vite:

- `src/{atoms,molecules,organisms,templates,pages}/` directory stubs
  (each with a `.gitkeep` or a trivial placeholder component), per
  `AGENTS.md`'s atomic-design guidance.
- `tsconfig.json` with `"strict": true`.
- A minimal `src/App.tsx` and `src/main.tsx` that render successfully
  (`npm run build` must succeed with zero content beyond the stubs).
- `package.json` with `dev`/`build`/`test` scripts (`test` runs
  Vitest, even if there's only a placeholder test initially — CI needs
  a real command to run, not another `echo` placeholder).

`backend/` — Node + Express + TypeScript:

- `src/{domain,application,infrastructure}/` directory stubs, per
  `AGENTS.md`'s hexagonal-architecture guidance.
- A `/health` endpoint (per `AGENTS.md`'s Monitoring & observability
  section, which requires health check endpoints), implemented in the
  infrastructure layer.
- `tsconfig.json` with `"strict": true`.
- `package.json` with `dev`/`build`/`test` scripts (Vitest or Jest —
  implementation picks one, consistently).

Root-level guardrails, copied from `software-factory` as-is (already
self-contained/generic, no adaptation needed):

- `.pre-commit-config.yaml`, `commitlint.config.cjs`, `.gitleaksignore`
- `.github/workflows/ci.yml` — the `commitlint`/`secret-scan` jobs
  carry over unchanged; the `test` job's placeholder `echo` is replaced
  with real steps: install + `npm test` in `frontend/`, install +
  `npm test` in `backend/`.

### 4. Validation

The real test of a "one-click jumpstart" template is generating an
actual project from it, not just inspecting the template's own files:

1. `gh repo create ameetmadan/fullstack-app-demo --template
ameetmadan/fullstack-app-template` to generate a real project from
   the template.
2. Clone it with `--recurse-submodules`, confirm `.factory/AGENTS.md`
   is populated (submodule resolved correctly) and `CLAUDE.md`'s
   import works.
3. `npm install && npm run build` in both `frontend/` and `backend/`,
   confirm both succeed.
4. Confirm the demo repo's own CI (inherited from the template) runs
   and is green — commitlint, secret-scan, and now-real frontend/backend
   tests.
5. Keep `fullstack-app-demo` as a visible, working example (per
   discussion) rather than deleting it — future users can see exactly
   what "Use this template" produces.

## Open questions

None outstanding — all decisions above were confirmed during
brainstorming, including the explicit trade-off accepted on the
submodule approach (clone/update friction vs. a real git-level
connection back to `software-factory`).

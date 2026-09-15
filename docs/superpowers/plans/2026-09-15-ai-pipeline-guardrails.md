# AI Pipeline & Guardrails Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up the AI conventions layer (AGENTS.md/CLAUDE.md), GitHub-Issues-based roadmap tracking, two project skills (`roadmap`, `new-subproject`), and commit/secret/test guardrails for the `software-factory` repo — the foundation the other five factory pieces build on.

**Architecture:** Pure tooling/config repo, no application code. Conventions live in one self-contained `AGENTS.md`, consumed by `CLAUDE.md` via Claude Code's `@`-import and by Cursor natively. Roadmap state lives in GitHub Issues (labels + form templates), not in chat or local files. Guardrails run twice — locally via `pre-commit`, and again in GitHub Actions as a backstop that can't be skipped with `--no-verify`.

**Tech Stack:** `pre-commit` framework, commitlint (`@commitlint/config-conventional`), gitleaks, GitHub Actions, `gh` CLI, Claude Code skills (Markdown + YAML frontmatter).

**Spec:** `docs/superpowers/specs/2026-09-15-ai-pipeline-guardrails-design.md`

## Global Constraints

- Conventional commit types: `feat:`, `fix:`, `docs:`, `refactor:` (others like `chore:`, `test:` are also valid conventional-commit types and are allowed, but these four are the ones explicitly named in the conventions).
- Branch naming: `feature/*`, `bugfix/*`.
- Label set (exact names): `epic`, `task`, `ai-pipeline`, `discovery`, `scaffolding`, `ci`, `iac`, `deploy`.
- No content in this repo may assume the maintainer's global Claude Code config (global `CLAUDE.md`, `pstack`, `superpowers`) is present — everything must be self-contained.
- Skill files use YAML frontmatter with `name` and `description` fields, per Claude Code skill format.

---

### Task 1: Docs layer (AGENTS.md, CLAUDE.md, Cursor pointer)

**Files:**

- Create: `AGENTS.md`
- Create: `CLAUDE.md`
- Create: `.cursor/rules/agents.mdc`

**Interfaces:**

- Consumes: nothing (first task).
- Produces: `AGENTS.md` as the canonical conventions doc every later file (README, skills) refers back to. `CLAUDE.md` imports it via `@AGENTS.md`.

- [ ] **Step 1: Write `AGENTS.md`**

````markdown
# Agent & Contributor Conventions

This file is the single source of truth for how this repo is built and
how AI coding assistants should work in it. `CLAUDE.md` imports it for
Claude Code; Cursor reads it natively; any other tool should be pointed
at this file directly. It is self-contained — do not assume any
assistant's global/user-level config is present.

## What this repo is

`software-factory` is a template repo for jumpstarting new project ideas,
covering the full lifecycle from requirements analysis through
infrastructure-as-code and deployment. It is built as six independent
sub-projects, each with its own design spec and implementation plan under
`docs/superpowers/specs/` and `docs/superpowers/plans/`:

1. AI pipeline & guardrails (this one)
2. Discovery/planning kit
3. Project scaffolding/generator
4. CI pipeline templates
5. IaC modules
6. Deployment automation

## Issue tracking

GitHub Issues is the persistence layer for roadmap state — not chat
history, not local todo files. Each of the six pieces above is an `epic`
issue; concrete work under a piece is a `task` issue linked to its epic.
Labels: `epic`, `task`, plus one piece label per piece
(`ai-pipeline`, `discovery`, `scaffolding`, `ci`, `iac`, `deploy`). Use the
`roadmap` skill to create or update issues, and `new-subproject` to kick
off the next piece's design cycle.

## Working with AI agents

- Skills live in `.claude/skills/`. Read a skill's `SKILL.md` before
  performing the workflow it covers.
- Follow the brainstorming → spec → plan cycle for any new sub-project:
  classify scope, get design approval before writing code, write a spec
  to `docs/superpowers/specs/`, then a plan to `docs/superpowers/plans/`.
- Don't implement ahead of an approved design for anything that isn't a
  trivial, obviously-scoped change.

## Git workflow

- Conventional commits: `feat:`, `fix:`, `docs:`, `refactor:` (and other
  standard types as needed).
- Branch naming: `feature/*`, `bugfix/*`, branched from `main`.
- Keep commits atomic and focused; explain _why_, not just _what_.
- Run tests before committing.
- Rebase feature branches on `main` before opening a PR; squash on merge.

## Security

- Never log sensitive data (passwords, API keys, PII).
- Validate and sanitize all user input at system boundaries.
- Use environment variables for secrets — never commit them (this repo's
  pre-commit hooks scan for secrets on every commit).
- Implement authentication/authorization checks and rate limiting on any
  public endpoint.
- Set CSP and standard security headers (HSTS, X-Frame-Options, etc.) on
  any frontend.
- Review OWASP Top 10 categories when touching request-handling code.

## Code quality

- Comprehensive error handling; unit tests for new functionality.
- TypeScript strict mode where applicable; follow the project's ESLint
  config.
- Self-documenting code — comment only the non-obvious _why_.
- Boy Scout Rule: leave touched code cleaner than you found it.
- Be mindful of performance; avoid premature optimization.
- WCAG 2.1 AA minimum for any frontend.

## Architecture

**Frontend:** component-based, atomic design (atoms → molecules →
organisms → templates → pages). Lift state only as high as needed; local
state for component-specific data; centralized state (e.g. Zustand) only
when state spans many distant components, needs complex separated logic,
or must persist across routes. Error boundaries required. Lazy-load and
code-split large apps.

**Backend:** hexagonal/clean architecture for medium+ projects — domain
layer (framework-independent business logic), application layer (use
cases/orchestration), infrastructure layer (DB, external APIs,
frameworks), all technical dependencies behind interfaces. Layered
architecture is sufficient for small services (<5 endpoints). Prefer
composition over inheritance, dependency injection for testability,
SOLID principles. Consider CQRS for complex domains, event-driven
patterns for async work.

**General:** design for testability from the start; domain logic testable
without infrastructure; business rules independent of frameworks.

## API design

- RESTful conventions or GraphQL schema best practices; semantic HTTP
  methods; version APIs (`/api/v1/*`).
- Consistent response shape:

```json
{
  "data": {},
  "error": null,
  "meta": { "timestamp": "..." }
}
```
````

- Proper HTTP status codes; pagination on list endpoints; OpenAPI/GraphQL
  schema docs; clear validation error messages.

## Testing strategy

- Test pyramid: Unit (70%) > Integration (20%) > E2E (10%).
- Mock external dependencies in unit tests; use real dependencies in
  integration tests where practical.
- Aim for 80%+ coverage, 100% on critical paths.
- TDD for bug fixes: write the failing test first.
- Keep tests fast, independent, deterministic.

## Performance

**Frontend:** initial bundle under 200KB gzipped; lazy-load routes and
heavy components; optimize images; tree-shake; CDN for static assets;
monitor Core Web Vitals.

**Backend:** index columns used in WHERE/JOIN; paginate large datasets;
cache expensive operations; fix N+1 queries; connection pooling; query
timeouts; monitor slow queries.

## Monitoring & observability

- Structured (JSON) logging with correlation IDs for request tracing.
- Log levels: ERROR (production), WARN (potential issues), INFO
  (important events), DEBUG (development only).
- Monitor response time, error rate, throughput, resource usage
  (backend) and page load time, JS errors, API latency (frontend).
- Health check endpoints (`/health`, `/ready`); alerts on critical
  failures.

## Documentation

- Keep the README current with setup instructions.
- Record architectural decisions (ADRs) for major choices.
- Keep API docs current; document complex algorithms/business rules;
  include diagrams for system architecture.
- PR descriptions explain _why_, including trade-offs, so the reasoning
  still makes sense years later.

````

- [ ] **Step 2: Write `CLAUDE.md`**

```markdown
# software-factory

@AGENTS.md
````

- [ ] **Step 3: Write `.cursor/rules/agents.mdc`**

```markdown
---
description: Project conventions (imports AGENTS.md)
alwaysApply: true
---

See @AGENTS.md for full project conventions: git workflow, security, code
quality, architecture, API design, testing, performance, observability,
and documentation standards. This file exists only so Cursor loads those
conventions automatically — do not duplicate content here.
```

- [ ] **Step 4: Verify the Claude Code import resolves**

Run: `claude -p "Reply with the exact text of the 'Branch naming' line from your loaded project conventions." --cwd /Users/ameetmadan/Workspace/software-factory`

Expected: the response includes `feature/*`, `bugfix/*` — confirming `CLAUDE.md`'s `@AGENTS.md` import loaded into context. If the `claude` CLI isn't scriptable this way in the execution environment, instead open a fresh Claude Code session in this repo and ask the same question interactively; confirm the answer matches `AGENTS.md`.

- [ ] **Step 5: Commit**

```bash
git add AGENTS.md CLAUDE.md .cursor/rules/agents.mdc
git commit -m "docs: add self-contained AGENTS.md conventions and CLAUDE.md/Cursor imports"
```

---

### Task 2: Issue templates and label bootstrap script

**Files:**

- Create: `.github/ISSUE_TEMPLATE/epic.yml`
- Create: `.github/ISSUE_TEMPLATE/task.yml`
- Create: `scripts/bootstrap-labels.sh`

**Interfaces:**

- Consumes: nothing.
- Produces: the exact label set (`epic`, `task`, `ai-pipeline`, `discovery`, `scaffolding`, `ci`, `iac`, `deploy`) that Task 3 (roadmap epics), Task 6 (`roadmap` skill), and Task 7 (`new-subproject` skill) all rely on by name.

- [ ] **Step 1: Write `.github/ISSUE_TEMPLATE/epic.yml`**

```yaml
name: Epic
description: A top-level software-factory sub-project (roadmap item)
title: "[Epic] "
labels: ["epic"]
body:
  - type: markdown
    attributes:
      value: |
        One epic per software-factory piece: ai-pipeline, discovery,
        scaffolding, ci, iac, deploy. Link the design doc once
        brainstorming produces one.
  - type: input
    id: piece
    attributes:
      label: Factory piece
      description: Which of the six pieces this covers
      placeholder: "e.g. scaffolding"
    validations:
      required: true
  - type: textarea
    id: scope
    attributes:
      label: Scope
      description: What's in and what's out for this piece
    validations:
      required: true
  - type: input
    id: spec
    attributes:
      label: Design doc path
      description: Path under docs/superpowers/specs/ once written
    validations:
      required: false
```

- [ ] **Step 2: Write `.github/ISSUE_TEMPLATE/task.yml`**

```yaml
name: Task
description: A concrete unit of work under an epic
title: ""
labels: ["task"]
body:
  - type: input
    id: epic
    attributes:
      label: Parent epic
      description: Issue number of the epic this task belongs to (e.g. #12)
    validations:
      required: true
  - type: textarea
    id: description
    attributes:
      label: What needs to happen
    validations:
      required: true
```

- [ ] **Step 3: Write `scripts/bootstrap-labels.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

# Creates the label set this repo's issue templates and skills rely on.
# Safe to re-run: --force updates existing labels instead of failing.

labels=(
  "epic|5319e7|Top-level software-factory sub-project"
  "task|1d76db|Concrete unit of work under an epic"
  "ai-pipeline|0e8a16|AI pipeline & guardrails sub-project"
  "discovery|fbca04|Discovery/planning kit sub-project"
  "scaffolding|f9d0c4|Project scaffolding/generator sub-project"
  "ci|c5def5|CI pipeline templates sub-project"
  "iac|bfd4f2|IaC modules sub-project"
  "deploy|d4c5f9|Deployment automation sub-project"
)

for entry in "${labels[@]}"; do
  IFS='|' read -r name color description <<< "$entry"
  gh label create "$name" --color "$color" --description "$description" --force
done

echo "Bootstrapped ${#labels[@]} labels."
```

- [ ] **Step 4: Make the script executable and run it**

Run: `chmod +x scripts/bootstrap-labels.sh && ./scripts/bootstrap-labels.sh`

Expected: output `Bootstrapped 8 labels.` with no errors (requires `gh auth status` to already be authenticated against the repo's remote).

- [ ] **Step 5: Verify the labels exist**

Run: `gh label list`

Expected: all 8 labels from Step 3 are listed.

- [ ] **Step 6: Commit**

```bash
git add .github/ISSUE_TEMPLATE/epic.yml .github/ISSUE_TEMPLATE/task.yml scripts/bootstrap-labels.sh
git commit -m "feat: add issue templates and label bootstrap script"
```

---

### Task 3: File the six-piece roadmap as epics

**Files:**

- None created — this task files GitHub issues, not repo files.

**Interfaces:**

- Consumes: label set from Task 2 (must be bootstrapped first).
- Produces: 6 open `epic` issues, one per factory piece, that Task 7's `new-subproject` skill and Task 8's README both reference.

- [ ] **Step 1: File the `ai-pipeline` epic (this sub-project, already in progress)**

```bash
gh issue create \
  --title "[Epic] AI pipeline & guardrails" \
  --label "epic,ai-pipeline" \
  --body "$(cat <<'EOF'
## Scope
Skills, AGENTS.md/CLAUDE.md conventions, GitHub Issues roadmap tracking,
and commit/secret/test guardrails — the foundation the other five factory
pieces build on.

## Design doc
docs/superpowers/specs/2026-09-15-ai-pipeline-guardrails-design.md
EOF
)"
```

- [ ] **Step 2: File the remaining five epics**

```bash
gh issue create --title "[Epic] Discovery/planning kit" --label "epic,discovery" \
  --body "## Scope
Requirements capture, feature scoping/prioritization, and ADR templates —
the very first step of a new project idea, before any code or AI tooling."

gh issue create --title "[Epic] Project scaffolding/generator" --label "epic,scaffolding" \
  --body "## Scope
Code templates for new projects (frontend/backend, per AGENTS.md
conventions), starting as a GitHub template repo; a CLI generator is a
later addition."

gh issue create --title "[Epic] CI pipeline templates" --label "epic,ci" \
  --body "## Scope
Reusable test/lint/build pipeline templates, layered on top of the
ai-pipeline sub-project's baseline commit/secret guardrails."

gh issue create --title "[Epic] IaC modules" --label "epic,iac" \
  --body "## Scope
Reusable infrastructure-as-code modules (hosting, DB, CDN, secrets) for
common architectures."

gh issue create --title "[Epic] Deployment automation" --label "epic,deploy" \
  --body "## Scope
The one-click deploy layer wiring IaC and CI together."
```

- [ ] **Step 3: Verify all six epics exist**

Run: `gh issue list --label epic --state all`

Expected: 6 issues listed, one per piece (`ai-pipeline`, `discovery`, `scaffolding`, `ci`, `iac`, `deploy`), each also carrying the `epic` label.

- [ ] **Step 4: No commit needed**

This task only creates GitHub issues, not repo files — nothing to commit. Proceed to Task 4.

---

### Task 4: Local pre-commit guardrails (commitlint + gitleaks)

**Files:**

- Create: `.pre-commit-config.yaml`
- Create: `commitlint.config.js`

**Interfaces:**

- Consumes: conventional commit types and label conventions from `AGENTS.md` (Task 1).
- Produces: the same commitlint config and hook set that Task 5's CI workflow mirrors.

- [ ] **Step 1: Write `commitlint.config.js`**

```javascript
module.exports = {
  extends: ["@commitlint/config-conventional"],
};
```

- [ ] **Step 2: Write `.pre-commit-config.yaml`**

```yaml
repos:
  - repo: https://github.com/alessandrojcm/commitlint-pre-commit-hook
    rev: v9.16.0
    hooks:
      - id: commitlint
        stages: [commit-msg]
        additional_dependencies: ["@commitlint/config-conventional"]

  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.21.2
    hooks:
      - id: gitleaks
```

- [ ] **Step 3: Install pre-commit and the hook scripts**

Run: `pip install pre-commit && pre-commit install --hook-type pre-commit --hook-type commit-msg`

Expected: `pre-commit installed at .git/hooks/pre-commit` and `.git/hooks/commit-msg`.

- [ ] **Step 4: Verify commitlint rejects a bad commit message**

Run:

```bash
git commit --allow-empty -m "bad message"
```

Expected: the commit is rejected with a commitlint error (message doesn't match conventional-commit format).

- [ ] **Step 5: Verify gitleaks rejects a planted secret**

Run:

```bash
echo 'AWS_SECRET_ACCESS_KEY=AKIAABCDEFGHIJKLMNOP' > /tmp/leak-test.env
cp /tmp/leak-test.env leak-test.env
git add leak-test.env
git commit -m "test: planted secret"
```

Expected: the commit is rejected by the gitleaks hook. Then clean up: `git reset && rm leak-test.env /tmp/leak-test.env`.

- [ ] **Step 6: Verify a clean, conventional commit succeeds**

Run:

```bash
git add .pre-commit-config.yaml commitlint.config.js
git commit -m "feat: add pre-commit guardrails for commit messages and secrets"
```

Expected: commit succeeds, both hooks pass.

---

### Task 5: CI backstop workflow

**Files:**

- Create: `.github/workflows/ci.yml`

**Interfaces:**

- Consumes: the same checks configured in Task 4 (commitlint config, gitleaks) — this workflow re-runs them server-side since local hooks can be bypassed with `--no-verify`.
- Produces: a `test` job placeholder that later sub-projects (scaffolding, CI templates) will replace with real test commands.

- [ ] **Step 1: Write `.github/workflows/ci.yml`**

```yaml
name: CI

on:
  pull_request:
  push:
    branches: [main]

jobs:
  commitlint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: wagoid/commitlint-github-action@v6

  secret-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests (placeholder)
        run: echo "no app code yet -- later sub-projects wire real test commands into this job"
```

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "feat: add CI backstop for commit-lint, secret-scan, and test placeholder"
```

- [ ] **Step 3: Push and verify the workflow runs**

Run: `git push -u origin main` (or the current branch), then `gh run list --limit 1`

Expected: a run for the `CI` workflow appears and all three jobs (`commitlint`, `secret-scan`, `test`) complete successfully.

---

### Task 6: `roadmap` skill

**Files:**

- Create: `.claude/skills/roadmap/SKILL.md`

**Interfaces:**

- Consumes: the exact label set from Task 2/3 (`epic`, `task`, plus the six piece labels).
- Produces: the `roadmap` skill, invoked directly by users/agents and by Task 7's `new-subproject` skill for filing task issues.

- [ ] **Step 1: Write `.claude/skills/roadmap/SKILL.md`**

````markdown
---
name: roadmap
description: Create or update GitHub issues for software-factory roadmap items (epics) and concrete work (tasks). Use when starting new roadmap work, breaking an epic into tasks, or updating issue status.
---

# Roadmap

GitHub Issues are the persistence layer for this repo's roadmap — not
chat history, not local todos. Use this skill any time roadmap state
needs to change.

## Creating an epic

One epic per software-factory piece (`ai-pipeline`, `discovery`,
`scaffolding`, `ci`, `iac`, `deploy` — see `scripts/bootstrap-labels.sh`
for the full label set). Most pieces already have an epic filed; check
before creating a duplicate.

```bash
gh issue create \
  --title "[Epic] <piece name>" \
  --label "epic,<piece-label>" \
  --body "$(cat <<'EOF'
## Scope
<what's in / out for this piece>

## Design doc
<path once brainstorming produces docs/superpowers/specs/...>
EOF
)"
```
````

## Creating a task under an epic

```bash
gh issue create \
  --title "<concrete task>" \
  --label "task,<piece-label>" \
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

````

- [ ] **Step 2: Verify the skill files an issue**

Run: use the skill (or its documented `gh issue create` command directly) to file a throwaway task issue, e.g. `gh issue create --title "roadmap skill smoke test" --label "task,ai-pipeline" --body "Part of #<ai-pipeline epic number from Task 3>"`, confirm it appears via `gh issue list --label task`, then close it: `gh issue close <number> --comment "smoke test for roadmap skill"`.

- [ ] **Step 3: Commit**

```bash
git add .claude/skills/roadmap/SKILL.md
git commit -m "feat: add roadmap skill for GitHub Issues tracking"
````

---

### Task 7: `new-subproject` skill

**Files:**

- Create: `.claude/skills/new-subproject/SKILL.md`

**Interfaces:**

- Consumes: the `roadmap` skill (Task 6), the six epics filed in Task 3, and the spec-file convention (`docs/superpowers/specs/`).
- Produces: the `new-subproject` skill, the entry point for starting sub-projects 2–6.

- [ ] **Step 1: Write `.claude/skills/new-subproject/SKILL.md`**

```markdown
---
name: new-subproject
description: Kick off the spec-to-plan cycle for the next software-factory piece (discovery, scaffolding, ci, iac, or deploy). Use when starting design work on one of the five remaining roadmap pieces.
---

# New Subproject

Each software-factory piece gets its own spec → plan → implementation
cycle, the same way `ai-pipeline` did. This skill is the entry point for
starting the next one.

## Steps

1. Find the piece's epic issue: `gh issue list --label epic --search
"<piece>"`. If it doesn't exist yet, use the `roadmap` skill to create
   it first.
2. Invoke `superpowers:brainstorming` to design the piece. Treat it as
   architectural — new subsystem, no existing flow in this repo to
   extend. Reuse the six-piece roadmap context from `AGENTS.md` and the
   epic issue's scope section; do not re-decompose pieces that already
   have their own epic.
3. When the design doc is written and committed to
   `docs/superpowers/specs/`, update the epic issue: `gh issue comment
<epic-number> --body "Design doc: docs/superpowers/specs/<file>.md"`.
4. Invoke `superpowers:writing-plans` to turn the spec into an
   implementation plan.
5. As the plan produces concrete tasks, file each as a task issue linked
   to the epic via the `roadmap` skill, so GitHub Issues stays the source
   of truth for what's done vs. pending.

## Constraints

- Don't skip straight to implementation — every piece goes through the
  same brainstorming → spec → plan cycle `ai-pipeline` went through, so
  the roadmap docs stay consistent across pieces.
- Don't create a second epic for a piece that already has one; update the
  existing epic instead.
```

- [ ] **Step 2: Verify the skill is discoverable**

Run: start a fresh Claude Code session in this repo and confirm `new-subproject` appears in the available-skills listing (or run whatever skill-listing command the harness exposes).

- [ ] **Step 3: Commit**

```bash
git add .claude/skills/new-subproject/SKILL.md
git commit -m "feat: add new-subproject skill to start the next factory piece"
```

---

### Task 8: README

**Files:**

- Create: `README.md` (overwrite the placeholder created by the initial commit)

**Interfaces:**

- Consumes: everything from Tasks 1–7 (docs layer, labels, epics, guardrails, skills).
- Produces: nothing further consumes this — it's the final, human-facing deliverable of this sub-project.

- [ ] **Step 1: Write `README.md`**

````markdown
# software-factory

A template repo for jumpstarting new project ideas — covering the full
lifecycle from requirements analysis through infrastructure-as-code and
one-click deployment.

Conventions for both humans and AI coding assistants live in
[`AGENTS.md`](./AGENTS.md) (imported automatically by `CLAUDE.md` for
Claude Code, and natively by Cursor).

## Roadmap

Built as six independent sub-projects, each tracked as a GitHub Issues
epic (label `epic`) with its own design spec and implementation plan
under `docs/superpowers/specs/` and `docs/superpowers/plans/`:

1. **AI pipeline & guardrails** — this sub-project: skills, conventions,
   GitHub Issues roadmap tracking, commit/secret/test guardrails.
2. **Discovery/planning kit** — requirements capture, feature
   scoping/prioritization, ADRs.
3. **Project scaffolding/generator** — code templates for new projects.
4. **CI pipeline templates** — reusable test/lint/build automation.
5. **IaC modules** — reusable infrastructure-as-code.
6. **Deployment automation** — the one-click deploy layer.

See current status: `gh issue list --label epic --state all`.

## Skills

- `roadmap` — create/update GitHub issues for epics and tasks.
- `new-subproject` — kick off the spec → plan cycle for the next factory
  piece.

## Setup (for a new clone or template use)

```bash
# Install and enable local guardrails
pip install pre-commit
pre-commit install --hook-type pre-commit --hook-type commit-msg

# Bootstrap the label set this repo's issues/skills rely on
./scripts/bootstrap-labels.sh
```
````

Then, in your GitHub repo settings, enable **required status checks** on
`main` for the `CI` workflow (`commitlint`, `secret-scan`, `test`) —
branch protection is a repo setting and can't be expressed in code.

## Guardrails

Every commit is checked locally (via `pre-commit`) and again in CI (since
local hooks can be bypassed with `--no-verify`):

- Commit messages must follow [Conventional
  Commits](https://www.conventionalcommits.org/).
- No secrets/API keys committed (scanned via
  [gitleaks](https://github.com/gitleaks/gitleaks)).
- Tests run in CI (`test` job — currently a placeholder until the
  scaffolding/CI sub-projects add real app code and test commands).

````

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: write README covering roadmap, skills, and setup"
````

- [ ] **Step 3: Update the `ai-pipeline` epic and close it**

```bash
gh issue comment <ai-pipeline-epic-number> --body "README, docs layer, roadmap tracking, skills, and guardrails all implemented and verified — see docs/superpowers/plans/2026-09-15-ai-pipeline-guardrails.md."
gh issue close <ai-pipeline-epic-number> --comment "Sub-project complete."
```

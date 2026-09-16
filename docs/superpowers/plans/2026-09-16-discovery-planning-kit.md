# Discovery/Planning Kit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a generic (not software-factory-specific) discovery/planning kit — a `discovery` skill for requirements capture, a `prioritize-features` skill for RICE-scored feature backlogs filed as GitHub issues, and an ADR template — that ships as part of the conventions layer to every project started from this factory.

**Architecture:** Two Claude Code skills plus three Markdown templates, no application code. The skills fill in the templates and, for feature prioritization, also file GitHub issues in the _consuming_ project's own repo. `AGENTS.md` gains one new section pointing to both skills, mirroring how it already documents the `roadmap` skill from sub-project 1.

**Tech Stack:** Claude Code skills (Markdown + YAML frontmatter), Markdown templates, `gh` CLI.

**Spec:** `docs/superpowers/specs/2026-09-16-discovery-planning-kit-design.md`

## Global Constraints

- Generic and self-contained: nothing in the templates or skills may reference `software-factory`'s own specific labels (`epic`, `task`, `ai-pipeline`, `discovery`, `scaffolding`, `ci`, `iac`, `deploy`) or its roadmap — a consuming project only gets a `feature` label, nothing more.
- RICE formula (exact): `Score = (Reach × Impact × Confidence) / Effort`, each factor scored 1–10.
- Skill files use YAML frontmatter with `name` and `description` fields, per Claude Code skill format (established in sub-project 1).
- Conventional commit types: `feat:`, `fix:`, `docs:`, `refactor:` (per `AGENTS.md`).

---

### Task 1: Templates

**Files:**

- Create: `templates/discovery/requirements.md`
- Create: `templates/discovery/feature-backlog.md`
- Create: `templates/discovery/adr.md`

**Interfaces:**

- Consumes: nothing (first task).
- Produces: the three template paths that Task 2 (`discovery` skill) and Task 3 (`prioritize-features` skill) copy from by exact path.

- [ ] **Step 1: Write `templates/discovery/requirements.md`**

```markdown
# <Project Name> — Requirements

## Purpose

<One or two sentences: what is this project and why does it exist?>

## Target users

<Who uses this? What do they need that they don't have today?>

## Constraints

<Technical, business, timeline, or resource constraints that shape the
solution.>

## Success criteria

<How will you know this project succeeded? Concrete, checkable outcomes,
not vague goals.>

## Open questions

<Anything still unresolved — decide these before or during design, not
silently.>
```

- [ ] **Step 2: Write `templates/discovery/feature-backlog.md`**

```markdown
# <Project Name> — Feature Backlog

RICE score = (Reach × Impact × Confidence) / Effort. Each factor is scored
1–10; higher Effort means more work, so it divides the score down.

| Feature                 | Reach | Impact | Confidence | Effort | Score | Rank |
| ----------------------- | ----- | ------ | ---------- | ------ | ----- | ---- |
| <example: "CSV export"> | 7     | 6      | 8          | 3      | 11.2  | 1    |

Each row above is also filed as a GitHub issue labeled `feature`, carrying
the same breakdown in its body — this table is the human-readable summary,
the issues are the workable form.
```

- [ ] **Step 3: Write `templates/discovery/adr.md`**

```markdown
# ADR-<NNNN>: <Title>

## Status

<Proposed | Accepted | Superseded by ADR-XXXX>

## Context

<What forces are at play? What decision are we facing?>

## Decision

<What did we decide?>

## Consequences

<What becomes easier or harder as a result? Trade-offs, not just
benefits.>
```

- [ ] **Step 4: Commit**

```bash
git add templates/discovery/requirements.md templates/discovery/feature-backlog.md templates/discovery/adr.md
git commit -m "feat: add discovery/planning kit templates"
```

---

### Task 2: `discovery` skill

**Files:**

- Create: `.claude/skills/discovery/SKILL.md`

**Interfaces:**

- Consumes: `templates/discovery/requirements.md` (Task 1) by exact path.
- Produces: the `discovery` skill, referenced by Task 4's `AGENTS.md` section and exercised for real in Task 5's validation.

- [ ] **Step 1: Write `.claude/skills/discovery/SKILL.md`**

```markdown
---
name: discovery
description: Capture requirements for a new project idea — purpose, target users, constraints, success criteria. Use when starting a brand-new project idea, before any code or AI tooling exists.
---

# Discovery

Before any code exists, capture what this project idea actually is. This
skill produces `docs/discovery/requirements.md` from
`templates/discovery/requirements.md`.

## Steps

1. Copy `templates/discovery/requirements.md` to
   `docs/discovery/requirements.md` if it doesn't already exist.
2. Ask the user, one at a time, for each section:
   - **Purpose** — what is this project and why does it exist?
   - **Target users** — who uses this? What do they need that they don't
     have today?
   - **Constraints** — technical, business, timeline, or resource
     constraints that shape the solution.
   - **Success criteria** — how will you know this project succeeded?
     Push for concrete, checkable outcomes, not vague goals.
3. Fill in each section with the user's answers as you go — don't wait
   until the end to write everything at once.
4. Leave anything genuinely unresolved in **Open questions** rather than
   guessing — surface it, don't silently decide it.
5. Commit `docs/discovery/requirements.md`.

## Constraints

- Ask one question at a time — this is a conversation, not a form dump.
- Don't move to feature prioritization (`prioritize-features` skill) until
  requirements are captured — features should be scored against a known
  purpose, not before one exists.
```

- [ ] **Step 2: Commit**

```bash
git add .claude/skills/discovery/SKILL.md
git commit -m "feat: add discovery skill for requirements capture"
```

---

### Task 3: `prioritize-features` skill

**Files:**

- Create: `.claude/skills/prioritize-features/SKILL.md`

**Interfaces:**

- Consumes: `templates/discovery/feature-backlog.md` (Task 1) by exact path; references `docs/discovery/requirements.md` as a precondition (produced at runtime by the `discovery` skill, Task 2).
- Produces: the `prioritize-features` skill, referenced by Task 4's `AGENTS.md` section and exercised for real in Task 5's validation.

- [ ] **Step 1: Write `.claude/skills/prioritize-features/SKILL.md`**

```markdown
---
name: prioritize-features
description: Score a candidate feature list with RICE (Reach, Impact, Confidence, Effort) and file each as a GitHub issue. Use when a project has requirements captured and needs to turn feature ideas into a ranked, workable backlog.
---

# Prioritize Features

Turns a list of feature ideas into a ranked backlog using RICE scoring,
and files each as a trackable GitHub issue.

## RICE scoring

```
Score = (Reach × Impact × Confidence) / Effort
```

Each factor scored 1–10:

- **Reach** — how many users/how often this matters
- **Impact** — how much it moves the needle when it lands
- **Confidence** — how sure you are about the Reach/Impact estimates
- **Effort** — relative cost to build (higher = more effort, which divides
  the score down)

## Steps

1. Collect the candidate feature list from the user (one-line description
   each).
2. For each feature, ask for or estimate Reach/Impact/Confidence/Effort
   (1–10 each), and compute the score.
3. Copy `templates/discovery/feature-backlog.md` to
   `docs/discovery/feature-backlog.md` if it doesn't already exist, and
   write one row per feature, sorted by score descending, with rank
   assigned in that order.
4. File each feature as a GitHub issue in the current repo:

```bash
gh issue create \
  --title "<feature name>" \
  --label "feature" \
  --body "<one-line description>

RICE: Reach=<R> Impact=<I> Confidence=<C> Effort=<E> Score=<S> Rank=<N>"
```

5. Commit `docs/discovery/feature-backlog.md`.

## Constraints

- Score features against the project's captured requirements
  (`docs/discovery/requirements.md`, from the `discovery` skill) — if
  that file doesn't exist yet, run `discovery` first.
- Don't invent a different label scheme — always `feature`, no epic/task
  split. This kit is generic; project-specific tracking conventions (if
  any) layer on top separately.
```

- [ ] **Step 2: Commit**

```bash
git add .claude/skills/prioritize-features/SKILL.md
git commit -m "feat: add prioritize-features skill for RICE-scored backlogs"
```

---

### Task 4: `AGENTS.md` update

**Files:**

- Modify: `AGENTS.md` (insert a new section after "Working with AI agents", before "Git workflow")

**Interfaces:**

- Consumes: skill names `discovery` and `prioritize-features` (Tasks 2/3), template directory `templates/discovery/` (Task 1).
- Produces: nothing further consumes this — it's the discoverability entry point for a human/agent landing in the repo.

- [ ] **Step 1: Insert the new section into `AGENTS.md`**

Find this existing text in `AGENTS.md` (the end of the "Working with AI
agents" section):

```markdown
- Don't implement ahead of an approved design for anything that isn't a
  trivial, obviously-scoped change.

## Git workflow
```

Replace it with (inserting the new section between the two):

```markdown
- Don't implement ahead of an approved design for anything that isn't a
  trivial, obviously-scoped change.

## Starting a new project idea

Before any code or AI tooling exists for a new project, capture what it
actually is and rank what to build first:

- `discovery` skill — captures requirements (purpose, target users,
  constraints, success criteria) into `docs/discovery/requirements.md`.
- `prioritize-features` skill — RICE-scores a candidate feature list into
  `docs/discovery/feature-backlog.md` and files each as a
  `feature`-labeled GitHub issue.
- Both skills fill in templates from `templates/discovery/` (also home to
  an `adr.md` template for recording architectural decisions, per the
  Documentation section below).

## Git workflow
```

- [ ] **Step 2: Commit**

```bash
git add AGENTS.md
git commit -m "docs: document discovery/planning kit in AGENTS.md"
```

---

### Task 5: Validation — run both skills for real

**Files:**

- Create: `docs/discovery/requirements.md` (via the `discovery` skill, Task 2)
- Create: `docs/discovery/feature-backlog.md` (via the `prioritize-features` skill, Task 3)
- No new skill/template files — this task exercises Tasks 1–3's deliverables end to end and keeps the result as a worked example in the repo.

**Interfaces:**

- Consumes: `discovery` skill (Task 2), `prioritize-features` skill (Task 3), both templates (Task 1).
- Produces: a worked example future users of this kit can read; real GitHub issues labeled `feature` in this repo.

- [ ] **Step 1: Run the `discovery` skill against a small example idea**

Use the example idea "a personal habit-tracking CLI" (chosen because it's
small enough to fill in convincingly in one pass, and has no overlap with
`software-factory` itself — this keeps the worked example clearly
recognizable as a sample, not real project planning). Follow
`.claude/skills/discovery/SKILL.md`'s steps: copy the template to
`docs/discovery/requirements.md`, fill in Purpose / Target users /
Constraints / Success criteria / Open questions with concrete example
content for a habit-tracking CLI (e.g. Purpose: "a CLI to log and review
daily habits without needing a phone app or account"; Target users:
"a single developer who wants a fast, scriptable way to track habits from
the terminal"; Constraints: "single-user, local-only, no server, no paid
dependencies"; Success criteria: "can log a habit completion in under 5
seconds, can view a 7-day streak view"; Open questions: "should history
sync across machines, or stay purely local?").

- [ ] **Step 2: Verify the requirements file**

Run: `cat docs/discovery/requirements.md`

Expected: all five sections present and filled in with concrete (not
placeholder-angle-bracket) content.

- [ ] **Step 3: Commit the requirements file**

```bash
git add docs/discovery/requirements.md
git commit -m "docs: add worked-example requirements from discovery skill"
```

- [ ] **Step 4: Run the `prioritize-features` skill against a short example feature list**

Using the same habit-tracking CLI idea, score 4 example features against
the RICE formula. Follow `.claude/skills/prioritize-features/SKILL.md`'s
steps: for each feature, pick plausible 1–10 values for Reach/Impact/
Confidence/Effort, compute `Score = (Reach × Impact × Confidence) /
Effort`, and rank by score descending. Example feature set (pick
realistic-looking scores, compute them for real rather than copying these
exact numbers verbatim):

- "Log a habit completion from the CLI"
- "7-day streak view"
- "Reminder notifications"
- "CSV export of history"

- [ ] **Step 5: Write and verify the feature backlog file**

Copy `templates/discovery/feature-backlog.md` to
`docs/discovery/feature-backlog.md`, write one row per feature from Step
4 with real computed scores, sorted by score descending with rank
assigned in that order.

Run: `cat docs/discovery/feature-backlog.md`

Expected: 4 rows, each with all six columns filled in, sorted by Score
descending, Rank column matching that sort order (1 = highest score).
Hand-verify one row's arithmetic: `Score = (Reach × Impact × Confidence) /
Effort` for that row's own numbers.

- [ ] **Step 6: File each feature as a real GitHub issue**

For each of the 4 features from Step 4/5, run:

```bash
gh issue create \
  --title "<feature name>" \
  --label "feature" \
  --body "<one-line description>

RICE: Reach=<R> Impact=<I> Confidence=<C> Effort=<E> Score=<S> Rank=<N>"
```

using that feature's real computed values from Step 4.

- [ ] **Step 7: Verify the issues were filed correctly**

Run: `gh issue list --label feature`

Expected: 4 open issues, one per feature, each labeled `feature`. Spot-check
one with `gh issue view <number>` and confirm its body's RICE line matches
the corresponding row in `docs/discovery/feature-backlog.md`.

- [ ] **Step 8: Commit the feature backlog file**

```bash
git add docs/discovery/feature-backlog.md
git commit -m "docs: add worked-example feature backlog from prioritize-features skill"
```

- [ ] **Step 9: Confirm self-containment**

Run: `grep -rn "ai-pipeline\|scaffolding\|iac\|deploy" templates/discovery/ .claude/skills/discovery/ .claude/skills/prioritize-features/`

Expected: no matches — confirms neither the templates nor the two new
skills reference any `software-factory`-specific label or piece name.

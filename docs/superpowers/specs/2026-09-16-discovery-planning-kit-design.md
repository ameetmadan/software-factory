# Discovery/Planning Kit — Design

## Context

`software-factory` is built as six independent sub-projects (see
`AGENTS.md`). Sub-project 1 (AI pipeline & guardrails) shipped the
conventions layer, GitHub Issues roadmap tracking, and guardrail
automation. This document covers sub-project 2: **discovery/planning
kit** — requirements capture, feature scoping/prioritization, and ADR
templates, per epic #2.

Unlike sub-project 1's tooling (which serves `software-factory`'s own
roadmap), this kit is **generic**: it ships as part of the conventions
layer to every project started from this factory, so a new project idea
gets working requirements/prioritization/ADR tooling from day one instead
of starting from a blank prompt — the same motivation that drove
sub-project 1.

## Goals

- Give a new project idea a structured requirements-capture step before
  any code or AI tooling exists.
- Give feature ideas a lightweight, well-known prioritization method
  (RICE) instead of ad-hoc judgment calls.
- Give major decisions a consistent ADR shape from day one.
- Stay self-contained and generic: no dependency on `software-factory`'s
  own specific labels, epics, or roadmap — a consuming project only needs
  _a_ feature backlog it can track, not software-factory's 6-piece
  scheme.

## Non-goals

- Not a replacement for `software-factory`'s own roadmap tracking (the
  `roadmap` skill, epic/task labels) — that stays specific to this repo.
- No interactive CLI/generator — skills + Markdown templates only, matching
  sub-project 1's footprint.
- No dedicated ADR-writing skill — the ADR template ships alongside a
  pointer in `AGENTS.md`'s existing "Documentation" guidance ("Record
  architectural decisions (ADRs) for major choices"), not as its own
  guided workflow.

## Design

### 1. Skills

- **`discovery`** (`.claude/skills/discovery/SKILL.md`) — walks through
  capturing a new project idea's requirements: purpose, target users,
  constraints, success criteria. Writes `docs/discovery/requirements.md`
  from `templates/discovery/requirements.md`.
- **`prioritize-features`** (`.claude/skills/prioritize-features/SKILL.md`)
  — RICE-scores a candidate feature list. Writes
  `docs/discovery/feature-backlog.md` from
  `templates/discovery/feature-backlog.md`, and files each feature as a
  GitHub issue in the _current_ (consuming) repo with a generic `feature`
  label.

### 2. RICE scoring convention

Simplified 1–10-per-factor RICE (favoring approachability over the
full reach-in-users/effort-in-weeks version):

```
Score = (Reach × Impact × Confidence) / Effort
```

- **Reach** (1–10): how many users/how often this matters
- **Impact** (1–10): how much it moves the needle when it lands
- **Confidence** (1–10): how sure we are about the Reach/Impact estimates
- **Effort** (1–10): relative cost to build (higher = more effort)

Each scored feature becomes a GitHub issue:

- Label: `feature` (single generic label — no epic/task split, no
  piece labels; those are `software-factory`-specific)
- Title: the feature name
- Body: one-line description + the four RICE inputs + computed score +
  rank among the batch scored together

`feature-backlog.md` is the human-readable summary table (sorted by
score); the issues are the workable/trackable form — the same
document-vs-issue split sub-project 1 used for `AGENTS.md`/`README.md`
vs. GitHub Issues.

### 3. Templates

`templates/discovery/`:

- `requirements.md` — sections: Purpose, Target users, Constraints,
  Success criteria, Open questions.
- `feature-backlog.md` — a scored table: Feature | Reach | Impact |
  Confidence | Effort | Score | Rank.
- `adr.md` — standard ADR shape: Title, Status, Context, Decision,
  Consequences.

### 4. Conventions-layer integration

`AGENTS.md` gains one new section, **"Starting a new project idea"**,
placed after "Working with AI agents": names the `discovery` and
`prioritize-features` skills and the `templates/discovery/` templates,
mirroring how the existing "Issue tracking" section already documents
the `roadmap` skill.

### 5. Repo structure

```
software-factory/
├── templates/discovery/
│   ├── requirements.md
│   ├── feature-backlog.md
│   └── adr.md
└── .claude/skills/
    ├── discovery/
    └── prioritize-features/
```

### Validation

No app code — validated behaviorally, and the validation run doubles as
a worked example kept in the repo (per discussion, not cleaned up
afterward):

- Run the `discovery` skill for real against a small example project idea;
  confirm it produces a well-formed `docs/discovery/requirements.md`.
- Run `prioritize-features` against a short example feature list; hand-check
  one row's RICE math; confirm it files real GitHub issues in this repo
  with the `feature` label and confirm `feature-backlog.md` matches the
  filed issues.
- Confirm both templates and both skills contain nothing specific to
  `software-factory`'s own labels/roadmap — self-contained and generic.

## Open questions

None outstanding — all decisions above were confirmed during
brainstorming.

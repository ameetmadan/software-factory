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
4. Ensure the `feature` label exists (idempotent, safe to re-run):

```bash
gh label create feature --color 0e8a16 --description "New feature candidate scored via RICE" --force
```

5. File each feature as a GitHub issue in the current repo:

```bash
gh issue create \
  --title "<feature name>" \
  --label "feature" \
  --body "<one-line description>

RICE: Reach=<R> Impact=<I> Confidence=<C> Effort=<E> Score=<S> Rank=<N>"
```

6. Commit `docs/discovery/feature-backlog.md`.

## Constraints

- Score features against the project's captured requirements
  (`docs/discovery/requirements.md`, from the `discovery` skill) — if
  that file doesn't exist yet, run `discovery` first.
- Don't invent a different label scheme — always `feature`, no epic/task
  split. This kit is generic; project-specific tracking conventions (if
  any) layer on top separately.

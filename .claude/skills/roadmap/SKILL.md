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

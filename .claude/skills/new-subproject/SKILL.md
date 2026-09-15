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

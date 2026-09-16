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

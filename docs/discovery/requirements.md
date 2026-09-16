# Habit Tracker CLI — Requirements

## Purpose

A CLI to log and review daily habits without needing a phone app or an
account. It exists so a developer can track habits from the same terminal
they already work in, with a single command, instead of context-switching
to a mobile app or web dashboard.

## Target users

A single developer who wants a fast, scriptable way to track habits from
the terminal. They're comfortable with the command line, already live in a
shell most of the day, and want tracking to cost them a few keystrokes —
not an app switch, a login, or a network round trip.

## Constraints

Single-user, local-only, no server, no paid dependencies. Must run
offline. Data is stored in a plain local file (e.g. SQLite or JSON) on the
user's own machine — no accounts, no sync service, no third-party API
keys. Ships as a single installable binary or script with no runtime
dependency heavier than what's already on a typical dev machine.

## Success criteria

- Can log a habit completion in under 5 seconds (single command, no
  prompts required for the common case).
- Can view a 7-day streak view for any tracked habit from a single
  command.
- Works fully offline, with zero setup beyond installing the binary.
- A first-time user can log their first habit and see it reflected in the
  streak view within 2 minutes of install, without reading documentation
  beyond `--help`.

## Open questions

- Should history sync across machines, or stay purely local?
- Should missed days be tracked explicitly (streak-breaking) or only
  successes recorded?
- Is a single global habit list sufficient, or do users need named
  habit "profiles" (e.g. separate lists for different areas of life)?

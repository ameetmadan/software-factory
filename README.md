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

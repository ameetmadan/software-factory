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

## Agent skills

### Issue tracker

Issues and PRDs live as markdown under `.scratch/<feature-slug>/`. See `docs/agents/issue-tracker.md`.

### Triage labels

Five canonical triage roles use the default label strings (mapped in issue file `Status:` lines). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout: `CONTEXT.md` at the repo root and `docs/adr/` for ADRs. See `docs/agents/domain.md`.

### Onboarding (humans)

New developers: start at [docs/新人入职.md](docs/新人入职.md) (Chinese, under `docs/`).

### Config vs run state

Design data is read-only on `table`; in-run stat changes go through `RunModifiers.resolve`. See `CONTEXT.md` and `docs/adr/0001-config-run-modifiers.md`.

### Run session

Per-run managers, arena binding, and Boss flow live on `RunSession`; player stats and damage formulas stay on `player_var`. See `docs/adr/0002-run-session-split.md`.

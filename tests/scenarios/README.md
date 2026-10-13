# Scenario harness

Headless `claude -p` runs of blend scenarios, to compare plugin variants.

Arms:
- `new`: this repo's `plugins/blend`, superpowers off, installed blend off.
- `old`: `$BLEND_OLD` (a 0.6.0 `plugins/blend` dir), superpowers on, installed blend off.
- `mixed`: this repo's `plugins/blend` with superpowers on, installed blend off.

Usage:

    tests/scenarios/scenario.sh <name> <out-dir> [arm]   # setup, run, check
    tests/scenarios/run.sh <arm> <workdir> <prompt-file> <out-prefix>
    tests/scenarios/setup.sh <fixture>
    ARMS=new tests/scenarios/outcome/run-outcome.sh <runs> <out-dir>

`scenario.sh` runs one named scenario and prints one `ok`/`FAIL` line per
check (exit 1 on any FAIL):

| Scenario | Fixture | Checks |
| --- | --- | --- |
| `brainstorm` | `cli-small` | planned due-date section in `features.md`, linked to the graphs (`:state :new` or `Touches:`), `intro.md` links the rest, all four files check ok, nothing outside `.blend/` changed |
| `build` | `cli-feature` + history: Todos built (`blend: built todos`), the Due dates section added after | own branch, default branch unmoved, due-date behavior works, Due dates marked built, plan is `.blend/plan.md`, gitignored / never committed / deleted, `blend: built` commit, strongest only for plan review or advisor (the 2-task fixture is below the plan-review threshold), code review on strong, every subagent names a model, graphs check ok |
| `build-empty` | `cli-feature` + `blend: built` at HEAD | empty spec diff: no code changed, no new `blend: built` commit |
| `persist-merge` | `persist-merge` + a persist commit, then a commit adding `app.export` | planned (`:state :new`) nodes and the planned Cache feature survive, new module added, `intro.md` written and linked, persist commit, staged user file not committed |
| `onboarding` | `cli-feature` + a staged file | `.blend/onboarding.md` checks ok, has slides with `architecture.edn` and `modules.edn` beside them (no `#id` links), presents Todos (built) and Due dates (planned), `docs: onboarding deck` commit holding only the deck, staged file not committed, the four spec files untouched |
| `persist-migrate` | `persist-migrate` | `.blend/views/` moved to `.blend/`, system.md removed, `.blend/features/` folded into `features.md` (Reader built), `intro.md` written, no marker line, old plan folder kept, staged file not committed |

`run.sh` honors `MODEL` (default `sonnet`) and `BLEND_OLD`; other env passes
through (e.g. `SIMPLEVIZ_HOME`). It writes `<out>.jsonl` and `<out>.txt` and
prints `<arm> turns=N in=N out=N cost=X superpowers_uses=N`.

`setup.sh` prints a fresh temp git repo (one commit, `fixture`) holding the fixture.

Fixtures:
- `cli-small`: small Python todo CLI with a test.
- `cli-feature`: cli-small plus `intro.md`, graphs and `features.md` with Todos (built) and Due dates (planned).
- `persist-merge`: Python/JS tree with flat `.blend/` graphs holding a planned `app-cache` module and `cache` component, `features.md` with Cache planned, no `intro.md`; scenario.sh adds a persist commit and an `app/export.py` commit.
- `persist-migrate`: the same code with the old `.blend/views/` layout, system.md, an old plan folder and an old `.blend/features/reader.md`.
- `failing-test`: Python `mean()` with a failing unittest.
- `blackboard`: clone of `${BLACKBOARD_REPO:-$HOME/repos/private/smpl-blackboard}` with history.
- `empty`: empty git repo.

Rule: a scenario never kills processes it did not start; stop servers by their PID only.

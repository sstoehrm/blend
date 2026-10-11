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
| `brainstorm` | `cli-small` | feature file written and linked to the graphs (`:state :new` or `Touches:`), graphs check ok, nothing outside `.blend/` changed |
| `build` | `cli-feature` + history: `todos.md` built (`blend: built todos`), `due-dates.md` added after | own branch, default branch unmoved, due-date behavior works, plan gitignored / never committed / deleted, `blend: built` commit, reviewer subagent ran, graphs check ok |
| `build-empty` | `cli-feature` + `blend: built` at HEAD | empty spec diff: no code changed, no new `blend: built` commit |
| `persist-merge` | `persist-merge` + a persist commit, then a commit adding `app.export` | planned (`:state :new`) nodes survive, new module added, persist commit, staged user file not committed |
| `persist-migrate` | `persist-migrate` | `.blend/views/` moved to `.blend/`, system.md removed, no marker line, old plan folder kept, staged file not committed |

`run.sh` honors `MODEL` (default `sonnet`) and `BLEND_OLD`; other env passes
through (e.g. `SIMPLEVIZ_HOME`). It writes `<out>.jsonl` and `<out>.txt` and
prints `<arm> turns=N in=N out=N cost=X superpowers_uses=N`.

`setup.sh` prints a fresh temp git repo (one commit, `fixture`) holding the fixture.

Fixtures:
- `cli-small`: small Python todo CLI with a test.
- `cli-feature`: cli-small plus graphs and two features: `todos.md` (built) and `due-dates.md` (not built).
- `persist-merge`: Python/JS tree with flat `.blend/` graphs holding a planned `app-cache` module and `cache` component; scenario.sh adds a persist commit and an `app/export.py` commit.
- `persist-migrate`: the same code with the old `.blend/views/` layout, system.md and an old plan folder.
- `failing-test`: Python `mean()` with a failing unittest.
- `blackboard`: clone of `${BLACKBOARD_REPO:-$HOME/repos/private/smpl-blackboard}` with history.
- `empty`: empty git repo.

Rule: a scenario never kills processes it did not start; stop servers by their PID only.

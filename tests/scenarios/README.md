# Scenario harness

Headless `claude -p` runs of blend scenarios, to compare plugin variants.

Arms:
- `new`: this repo's `plugins/blend`, superpowers off, installed blend off.
- `old`: `$BLEND_OLD` (a 0.6.0 `plugins/blend` dir), superpowers on, installed blend off.
- `mixed`: this repo's `plugins/blend` with superpowers on, installed blend off.

Usage:

    tests/scenarios/run.sh <arm> <workdir> <prompt-file> <out-prefix>
    tests/scenarios/setup.sh <fixture>

`run.sh` honors `MODEL` (default `sonnet`) and `BLEND_OLD`; other env passes
through (e.g. `SIMPLEVIZ_HOME`). It writes `<out>.jsonl` and `<out>.txt` and
prints `<arm> turns=N in=N out=N cost=X superpowers_uses=N`.

`setup.sh` prints a fresh temp git repo (one commit, `fixture`) holding the fixture.

Fixtures:
- `cli-small`: small Python todo CLI with a test, an existing flow to change.
- `csv-design`: CSV-to-JSON CLI design: plan graph without tasks, overview, both slices, empty project views.
- `csv-plan`: csv-design plus 3 task nodes and task files.
- `sync-plan`: tree for the view-sync scenario (project views, plan slices, code).
- `failing-test`: Python `mean()` with a failing unittest.
- `blackboard`: clone of `${BLACKBOARD_REPO:-$HOME/repos/private/smpl-blackboard}` with history.
- `empty`: empty git repo.

Rule: a scenario never kills processes it did not start; stop servers by their PID only.

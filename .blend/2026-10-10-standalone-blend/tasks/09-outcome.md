# Task 9: Outcome comparison — 0.6.0 + superpowers vs 0.7.0 alone

**Goal:** numbers for the question the scenario tests can't answer: does
standalone blend build working software at least as well, for fewer
tokens?

**Files:**
- Create: `tests/scenarios/outcome/acceptance_csv2json.py`,
  `tests/scenarios/outcome/acceptance_blackboard.sh`,
  `tests/scenarios/outcome/run-outcome.sh`
- Create: `.blend/2026-10-10-standalone-blend/outcome.md` (results)

**Interfaces:**
- Consumes: `run.sh` arms `old` and `new`, `setup.sh` fixtures `empty`
  and `blackboard` (task 1); the finished 0.7.0 plugin (task 8).

- [ ] **Step 1: Write the acceptance tests first**

`acceptance_csv2json.py <repo>` (stdlib; finds the CLI as
`<repo>/csv2json` executable, `python -m csv2json`, or
`<repo>/csv2json.py`, whichever exists):

```python
import csv, io, json, os, subprocess, sys, tempfile

repo = sys.argv[1]
cands = [[os.path.join(repo, "csv2json")], [sys.executable, "-m", "csv2json"],
         [sys.executable, os.path.join(repo, "csv2json.py")]]

def run(args, stdin=""):
    for c in cands:
        if os.path.exists(c[-1]) or c[1:2] == ["-m"]:
            p = subprocess.run(c + args, input=stdin, capture_output=True, text=True, cwd=repo)
            if p.returncode != 127 and "No module named" not in p.stderr:
                return p
    raise SystemExit("FAIL no runnable csv2json")

checks = 0
p = run([], "a,b\n1,2\n3,4\n")
assert json.loads(p.stdout) == [{"a": "1", "b": "2"}, {"a": "3", "b": "4"}], p.stdout; checks += 1
f = tempfile.NamedTemporaryFile("w", suffix=".csv", delete=False); f.write('n,q\nx,"a,b"\n'); f.close()
p = run([f.name])
assert json.loads(p.stdout) == [{"n": "x", "q": "a,b"}], p.stdout; checks += 1
p = run([], "a,b\n")
assert json.loads(p.stdout) == [], p.stdout; checks += 1
p = run(["/nonexistent.csv"])
assert p.returncode != 0 and p.stderr, "missing file must fail with a message"; checks += 1
print(f"PASS {checks}/4")
```

(Each failed `assert` exits non-zero; the script prints `PASS 4/4` only
when all pass.)

`acceptance_blackboard.sh <repo>`: in the repo, run its test suite
(`bb test` or the command its README names) — must pass — and grep that
tasks carry a due date and overdue tasks are flagged in both the API
(`src/`) and the UI (`public/`):

```sh
set -e
cd "$1"
bb test
grep -rqi "due" src && grep -rqi "overdue" src && grep -rqi "overdue" public
echo PASS
```

- [ ] **Step 2: Write run-outcome.sh**

```sh
#!/bin/sh
# Usage: tests/scenarios/outcome/run-outcome.sh <runs-per-arm> <out-dir>
set -u
here=$(cd "$(dirname "$0")" && pwd); n=$1 out=$2; mkdir -p "$out"
printf 'Load blend:brainstorming. Full auto. Build a Python CLI csv2json that converts a CSV file (argument) or stdin to a JSON array of objects on stdout, header row = keys; a missing file exits non-zero with an error message.\n' > "$out/green.txt"
printf 'Load blend:brainstorming. Full auto. Tasks get an optional due date; overdue tasks are flagged in the API and in the UI.\n' > "$out/brown.txt"
for arm in old new; do i=1; while [ $i -le "$n" ]; do
  w=$("$here/../setup.sh" empty);      "$here/../run.sh" $arm "$w" "$out/green.txt" "$out/green-$arm-$i" >> "$out/summary.txt"
  wt=$(cd "$w" && git worktree list --porcelain | awk '/^worktree/{p=$2} END{print p}')
  python3 "$here/acceptance_csv2json.py" "$wt" > "$out/green-$arm-$i.acc" 2>&1; echo "green $arm $i $(tail -1 "$out/green-$arm-$i.acc")" >> "$out/summary.txt"
  w=$("$here/../setup.sh" blackboard); "$here/../run.sh" $arm "$w" "$out/brown.txt" "$out/brown-$arm-$i" >> "$out/summary.txt"
  wt=$(cd "$w" && git worktree list --porcelain | awk '/^worktree/{p=$2} END{print p}')
  sh "$here/acceptance_blackboard.sh" "$wt" > "$out/brown-$arm-$i.acc" 2>&1; echo "brown $arm $i $(tail -1 "$out/brown-$arm-$i.acc")" >> "$out/summary.txt"
  i=$((i+1)); done; done
cat "$out/summary.txt"
```

(The work lands in the last worktree full auto created, or the repo
itself when it made none.) The `old` arm's prompts say
`blend:brainstorming` too — 0.6.0 has it.

- [ ] **Step 3: Smoke-test the acceptance scripts**

Write a 10-line correct `csv2json.py` in a temp dir and run
`acceptance_csv2json.py` on it: `PASS 4/4`. Run it on an empty dir:
`FAIL`. Run `acceptance_blackboard.sh` on an untouched blackboard clone:
fails at the grep (no "overdue").

- [ ] **Step 4: Run**

```sh
OLD=$(mktemp -d) && git archive claude/graph-native-plans plugins/blend | tar -x -C $OLD
BLEND_OLD=$OLD/plugins/blend sh tests/scenarios/outcome/run-outcome.sh 3 /tmp/outcome
```

Runs in the background; expect hours. If the user cut the comparison
to 1 run per arm, pass `1`.

- [ ] **Step 5: Write outcome.md**

`.blend/2026-10-10-standalone-blend/outcome.md`: a table per fixture —
arm, run, acceptance (PASS/FAIL), turns, tokens in/out, cost — then
per-arm means, and two sentences: pass rate old vs new, tokens old vs
new. Compare against the success criterion in overview.md; if 0.7.0 is
worse, say so plainly at the top.

- [ ] **Step 6: Commit**

```sh
git add tests/scenarios/outcome .blend/2026-10-10-standalone-blend/outcome.md
git commit -m "test: outcome comparison 0.6.0 + superpowers vs 0.7.0"
```

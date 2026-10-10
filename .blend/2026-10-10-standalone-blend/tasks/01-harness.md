# Task 1: Scenario harness and fixtures

**Goal:** one command runs a scenario headless with exactly the blend
under test — superpowers off for the new arm — and prints turns, tokens,
cost and how often superpowers was used.

**Files:**
- Create: `tests/scenarios/run.sh`, `tests/scenarios/setup.sh`,
  `tests/scenarios/README.md`
- Create: `tests/scenarios/fixtures/csv-design/` (T4 green A tree),
  `tests/scenarios/fixtures/csv-plan/` (T5 green A tree),
  `tests/scenarios/fixtures/sync-plan/` (T3 C tree),
  `tests/scenarios/fixtures/failing-test/`, `tests/scenarios/fixtures/cli-small/`

**Interfaces:**
- Produces: `run.sh <arm> <workdir> <prompt-file> <out-prefix>` with arm
  `new` | `old` | `mixed`; env `MODEL` (default `sonnet`), `BLEND_OLD` (old arm's
  plugin dir), any other env passes through (e.g. `SIMPLEVIZ_HOME`).
  Writes `<out>.jsonl`, `<out>.txt`, prints one line
  `<arm> turns=N in=N out=N cost=X superpowers_uses=N`.
- Produces: `setup.sh <fixture>` prints a fresh temp dir holding the
  fixture as a git repo with one commit `fixture`; fixture `blackboard`
  clones `${BLACKBOARD_REPO:-$HOME/repos/private/smpl-blackboard}` with
  its history; fixture `empty` is an empty git repo.

- [ ] **Step 1: Copy the fixtures**

```sh
S=/tmp/claude-1000/-home-soeren-repos-private-blend/ce7187b7-353c-4530-b601-8a9f9825dc5b/scratchpad
F=tests/scenarios/fixtures
mkdir -p $F/csv-design $F/csv-plan $F/sync-plan
git -C $S/t4/greenA archive 81d375e | tar -x -C $F/csv-design
git -C $S/t5/green2 archive 72433d4 | tar -x -C $F/csv-plan
git -C $S/t3/greenC-fixture archive 2bd889c | tar -x -C $F/sync-plan
```

If the scratchpad is gone: csv-design = a CSV→JSON CLI design (plan graph
without tasks, overview.md, both slices, empty project views);
csv-plan = the same plus 3 task nodes and task files; sync-plan = the
tree written by the scenario C script in
`.blend/2026-10-09-graph-native-plans/tasks/03-project-views.md`.

`$F/failing-test/` (Python, stdlib only):

```python
# stats.py
def mean(xs):
    return sum(xs) / len(xs) - 1
```

```python
# test_stats.py
import unittest
from stats import mean

class MeanTest(unittest.TestCase):
    def test_mean(self):
        self.assertEqual(mean([2, 4, 6]), 4)

if __name__ == "__main__":
    unittest.main()
```

`$F/cli-small/` (Python CLI, an existing flow to change):

```python
# todo.py
import json, sys
from pathlib import Path

DB = Path("todos.json")

def load():
    return json.loads(DB.read_text()) if DB.exists() else []

def main(argv):
    todos = load()
    if argv[:1] == ["add"]:
        todos.append({"text": " ".join(argv[1:]), "done": False})
        DB.write_text(json.dumps(todos))
    elif argv[:1] == ["list"]:
        for i, t in enumerate(todos, 1):
            print(f"{i}. [{'x' if t['done'] else ' '}] {t['text']}")

if __name__ == "__main__":
    main(sys.argv[1:])
```

```python
# test_todo.py
import json, os, tempfile, unittest
import todo

class TodoTest(unittest.TestCase):
    def setUp(self):
        os.chdir(tempfile.mkdtemp())
    def test_add_then_list(self):
        todo.main(["add", "buy", "milk"])
        self.assertEqual(json.loads(open("todos.json").read())[0]["text"], "buy milk")

if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Write setup.sh**

```sh
#!/bin/sh
# Copy a scenario fixture into a fresh temp git repo; print its path.
# Usage: tests/scenarios/setup.sh <fixture>   (a dir under fixtures/, or blackboard, or empty)
set -eu
here=$(cd "$(dirname "$0")" && pwd)
d=$(mktemp -d)
case $1 in
  blackboard) git clone -q "${BLACKBOARD_REPO:-$HOME/repos/private/smpl-blackboard}" "$d/repo"
              echo "$d/repo"; exit 0 ;;
  empty) ;;
  *) [ -d "$here/fixtures/$1" ] || { echo "no fixture $1" >&2; exit 2; }
     cp -R "$here/fixtures/$1/." "$d/" ;;
esac
cd "$d"
git init -q
git add -A
git -c user.name=fixture -c user.email=fixture@example.com commit -q --allow-empty -m fixture
echo "$d"
```

- [ ] **Step 3: Write run.sh**

```sh
#!/bin/sh
# Run one blend scenario headless and print a summary line.
# Usage: tests/scenarios/run.sh <arm> <workdir> <prompt-file> <out-prefix>
#   new: this repo's plugins/blend; superpowers and the installed blend off
#   old: $BLEND_OLD (a 0.6.0 plugins/blend dir); superpowers on, installed blend off
#   mixed: this repo's plugins/blend with superpowers on, installed blend off
set -eu
arm=$1 work=$2 prompt=$3 out=$4
root=$(cd "$(dirname "$0")/../.." && pwd)
case $arm in
  new) dir=$root/plugins/blend
       settings='{"enabledPlugins":{"superpowers@claude-plugins-official":false,"blend@blend":false}}' ;;
  old) dir=${BLEND_OLD:?set BLEND_OLD to a 0.6.0 plugins/blend dir}
       settings='{"enabledPlugins":{"blend@blend":false}}' ;;
  mixed) dir=$root/plugins/blend
       settings='{"enabledPlugins":{"blend@blend":false}}' ;;
  *) echo "arm must be new, old or mixed" >&2; exit 2 ;;
esac
case $prompt in /*) ;; *) prompt=$PWD/$prompt ;; esac
case $out in /*) ;; *) out=$PWD/$out ;; esac
cd "$work"
claude -p --model "${MODEL:-sonnet}" --settings "$settings" --plugin-dir "$dir" \
  --allowedTools "Bash Read Write Edit Glob Grep Skill Agent" \
  --output-format stream-json --verbose < "$prompt" > "$out.jsonl" || true
jq -r 'select(.type=="result") | .result // ""' "$out.jsonl" > "$out.txt"
uses=$(jq -c 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use")' "$out.jsonl" \
  | grep -c superpowers || true)
jq -r --arg arm "$arm" --arg uses "$uses" 'select(.type=="result")
  | "\($arm) turns=\(.num_turns) in=\((.usage.input_tokens // 0) + (.usage.cache_read_input_tokens // 0) + (.usage.cache_creation_input_tokens // 0)) out=\(.usage.output_tokens // 0) cost=\(.total_cost_usd) superpowers_uses=\($uses)"' "$out.jsonl"
```

`chmod +x` both scripts.

- [ ] **Step 4: Verify the harness**

```sh
OLD=$(mktemp -d) && git archive claude/graph-native-plans plugins/blend | tar -x -C $OLD
export BLEND_OLD=$OLD/plugins/blend
W=$(tests/scenarios/setup.sh empty)
printf 'List every skill available to you whose name starts with superpowers: or blend:, one per line. Then quote the first heading of the use-blend text injected at session start, if any.\n' > /tmp/p.txt
tests/scenarios/run.sh new $W /tmp/p.txt /tmp/h-new
tests/scenarios/run.sh old $W /tmp/p.txt /tmp/h-old
```

Expected: `/tmp/h-new.txt` lists only `blend:` skills and quotes
`# Use Blend`; `/tmp/h-old.txt` lists `superpowers:` skills too; both
summary lines print numbers, `superpowers_uses=0` for new.
`tests/scenarios/setup.sh csv-plan` prints a dir whose `git log` shows
`fixture`; `setup.sh blackboard` keeps the repo's history (9+ commits).

- [ ] **Step 5: Write README.md**

`tests/scenarios/README.md`: what the two arms are, the two scripts'
usage lines from above, the fixture list (one line each), and the rule
that a scenario never kills processes it did not start (stop servers by
their PID only).

- [ ] **Step 6: Commit**

```sh
git add tests/scenarios
git commit -m "test: headless scenario harness and fixtures"
```

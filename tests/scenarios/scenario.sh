#!/bin/sh
# Run one named blend scenario headless and check its result.
# Usage: tests/scenarios/scenario.sh <name> <out-dir> [arm]   (arm defaults to new)
# Names: brainstorm, build, persist-merge, persist-migrate
# Prints the run.sh summary line, then one "ok"/"FAIL" line per check.
set -u
here=$(cd "$(dirname "$0")" && pwd)
name=$1 out=$2 arm=${3:-new}
mkdir -p "$out"; out=$(cd "$out" && pwd); pre=$out/$name
case $name in
  brainstorm) fx=cli-small
    p="Use blend:brainstorming. I want todos to get optional due dates, and overdue ones should stand out in the list. I have to leave now — collect what we have so I can pick it up later." ;;
  build) fx=cli-feature
    p="Use blend:build for .blend/features/due-dates.md." ;;
  persist-merge) fx=persist-merge
    p="Use blend:persist with source git." ;;
  persist-migrate) fx=persist-migrate
    p="Use blend:persist with source git." ;;
  *) echo "unknown scenario $name" >&2; exit 2 ;;
esac
w=$("$here/setup.sh" "$fx") || exit 1
base=$(git -C "$w" rev-parse HEAD)
default=$(git -C "$w" branch --show-current)
# persist-merge: a valid marker, then a commit adding app.export, so the <marker>..HEAD path runs
if [ "$name" = persist-merge ]; then
  g() { git -C "$w" -c user.name=fixture -c user.email=fixture@example.com "$@"; }
  { echo ";; persisted-through: $base"; cat "$w/.blend/modules.edn"; } > "$w/m.tmp" && mv "$w/m.tmp" "$w/.blend/modules.edn"
  g commit -qam "marker"
  printf 'from . import util\n' > "$w/app/export.py"; echo 'from . import export' >> "$w/app/main.py"
  g add -A && g commit -qm "add export"
  base=$(git -C "$w" rev-parse HEAD)
fi
# persist scenarios: an unrelated staged file must stay out of persist's commit
case $name in persist-*) echo "user work" > "$w/notes.txt"; git -C "$w" add notes.txt ;; esac
printf '%s\n' "$p" > "$pre.prompt"
"$here/run.sh" "$arm" "$w" "$pre.prompt" "$pre"
echo "workdir $w"

fail=0
check() { if (cd "$w" && eval "$2") >/dev/null 2>&1; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }
committed() { git log --format= --name-only "$base..HEAD"; }
tools() { jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use") | "\(.name) \(.input|tostring)"' "$1.jsonl"; }
# edn <file> <get-in path>: prints the value, e.g. edn .blend/modules.edn '[:nodes :app-cache :state]'
edn() { bb -e "(prn (get-in (clojure.edn/read-string (slurp \"$1\")) $2))"; }
graphs_ok() { for f in .blend/architecture.edn .blend/modules.edn; do simpleviz check "$f" | grep -qx ok || return 1; done; }

case $name in
  brainstorm)
    check "feature file written" 'grep -qil due .blend/features/*.md'
    check "feature linked to graphs" 'grep -q ":state :new" .blend/architecture.edn .blend/modules.edn || grep -q "^Touches:.*#" .blend/features/*.md'
    check "graphs check ok" 'graphs_ok'
    check "nothing outside .blend changed" '[ -z "$( { git diff --name-only '"$base"'; git ls-files --others --exclude-standard; } | grep -v "^\.blend/")" ]'
    check "no build graph" '[ ! -e .blend/builds ]'
    check "todo.py untouched" 'git diff --quiet '"$base"' -- todo.py' ;;
  build)
    wt=$(git -C "$w" worktree list --porcelain | awk '/^worktree /{print $2}' | while read -r p; do
      [ "$(git -C "$p" rev-list --count "$base..HEAD")" -gt 0 ] && echo "$p"; done | head -1)
    [ -n "$wt" ] && w=$wt
    echo "build tree $w"
    check "not on $default" '[ "$(git branch --show-current)" != "'"$default"'" ]'
    check "$default not moved" '[ "$(git rev-parse '"$default"')" = "'"$base"'" ]'
    check "build graph, all done" 'ls .blend/builds/*.edn && ! grep -q ":state :\(new\|in-progress\|blocked\)" .blend/builds/*.edn && grep -q ":state :done" .blend/builds/*.edn'
    check "tests pass" 'python3 -m unittest -q'
    check "due date stored and listed" 'd=$(mktemp -d) && cp todo.py "$d" && cd "$d" && python3 todo.py add pay rent --due 2000-01-01 && python3 todo.py list | grep "pay rent" | grep -q "2000-01-01"'
    check "overdue flagged" 'd=$(mktemp -d) && cp todo.py "$d" && cd "$d" && python3 todo.py add pay rent --due 2000-01-01 && python3 todo.py list | grep -q OVERDUE'
    check "future not overdue" 'd=$(mktemp -d) && cp todo.py "$d" && cd "$d" && python3 todo.py add later --due 2999-01-01 && ! python3 todo.py list | grep -q OVERDUE'
    check "bad date rejected" 'd=$(mktemp -d) && cp todo.py "$d" && cd "$d" && ! python3 todo.py add x --due 2000-13-45 && [ "$(python3 todo.py list | wc -l)" -eq 0 ]'
    check "graphs exist and check ok" 'graphs_ok'
    check "reviewer subagent ran" 'tools "'"$pre"'" | grep -qi "^Agent.*review"'
    check "persist ran" 'tools "'"$pre"'" | grep -q "^Skill.*blend:persist\|^Read.*persist/SKILL.md"'
    check "work committed" '[ -z "$(git status --porcelain --untracked-files=no)" ]' ;;
  persist-merge)
    check "planned module kept" '[ "$(edn .blend/modules.edn "[:nodes :app-cache :state]")" = ":new" ]'
    check "planned component kept" '[ "$(edn .blend/architecture.edn "[:nodes :cache :state]")" = ":new" ]'
    check "marker advanced" 'head -n 1 .blend/modules.edn | grep -q "'"$base"'\|$(git rev-parse --short '"$base"')"'
    check "new module derived" 'grep -q "app-export" .blend/modules.edn'
    check "marker line" 'head -n 1 .blend/modules.edn | grep -q "^;; persisted-through: [0-9a-f]\{7,\}"'
    check "graphs check ok" 'graphs_ok'
    check "staged file not committed" '! committed | grep -qx notes.txt && git diff --cached --name-only | grep -qx notes.txt'
    check "only .blend committed" '[ -z "$(committed | grep -v "^\.blend/")" ]' ;;
  persist-migrate)
    check "views moved" '[ ! -e .blend/views/modules.edn ] && [ ! -e .blend/views/architecture.edn ] && [ -f .blend/modules.edn ] && [ -f .blend/architecture.edn ]'
    check "system.md removed" '[ ! -e .blend/views/system.md ]'
    check "old plan folder kept" '[ -d .blend/2026-10-09-csv ]'
    check "new module derived" 'grep -q "app-export" .blend/modules.edn'
    check "marker line" 'head -n 1 .blend/modules.edn | grep -q "^;; persisted-through: [0-9a-f]\{7,\}"'
    check "graphs check ok" 'graphs_ok'
    check "staged file not committed" '! committed | grep -qx notes.txt && git diff --cached --name-only | grep -qx notes.txt'
    check "only .blend committed" '[ -z "$(committed | grep -v "^\.blend/")" ]' ;;
esac
exit $fail

#!/bin/sh
# Run one named blend scenario headless and check its result.
# Usage: tests/scenarios/scenario.sh <name> <out-dir> [arm]   (arm defaults to new)
# Names: brainstorm, build, build-empty, persist-merge, persist-migrate
# Prints the run.sh summary line, then one "ok"/"FAIL" line per check.
set -u
here=$(cd "$(dirname "$0")" && pwd)
name=$1 out=$2 arm=${3:-new}
mkdir -p "$out"; out=$(cd "$out" && pwd); pre=$out/$name
case $name in
  brainstorm) fx=cli-small
    p="Use blend:brainstorming. I want todos to get optional due dates, and overdue ones should stand out in the list. I have to leave now — collect what we have so I can pick it up later." ;;
  build) fx=cli-feature
    p="Use blend:build." ;;
  build-empty) fx=cli-feature
    p="Use blend:build." ;;
  build-empty)
    check "no code changed" '[ -z "$(git diff --name-only '"$base"' -- . ":!.blend" ":!.gitignore")" ] && [ -z "$(git status --porcelain --untracked-files=all | grep -v " \.blend/\| \.gitignore$")" ]'
    check "no new build commit" '! git log --format=%s '"$base"'..HEAD | grep -q "^blend: built"' ;;
  persist-merge) fx=persist-merge
    p="Use blend:persist with source git." ;;
  persist-migrate) fx=persist-migrate
    p="Use blend:persist with source git." ;;
  *) echo "unknown scenario $name" >&2; exit 2 ;;
esac
w=$("$here/setup.sh" "$fx") || exit 1
base=$(git -C "$w" rev-parse HEAD)
default=$(git -C "$w" branch --show-current)
g() { git -C "$w" -c user.name=fixture -c user.email=fixture@example.com "$@"; }
case $name in
  # a persist commit, then a commit adding app.export, so the <last>..HEAD path runs
  persist-merge) g commit -q --allow-empty -m "docs: persist blend graphs"
    printf 'from . import util\n' > "$w/app/export.py"; echo 'from . import export' >> "$w/app/main.py"
    g add -A && g commit -qm "add export" ;;
  # Todos is built; the Due dates section is added after the last build, so it is the spec
  build) sed -i '/^## Due dates/,$d' "$w/.blend/features.md" && g commit -qam "todos"
    g commit -q --allow-empty -m "blend: built todos"
    g checkout -q "$base" -- .blend/features.md && g commit -qm "docs: brainstorm due dates" ;;
  # everything is built: the spec diff is empty
  build-empty) g commit -q --allow-empty -m "blend: built due-dates" ;;
esac
base=$(git -C "$w" rev-parse HEAD)
# persist scenarios: an unrelated staged file must stay out of persist's commit
case $name in persist-*) echo "user work" > "$w/notes.txt"; git -C "$w" add notes.txt ;; esac
printf '%s\n' "$p" > "$pre.prompt"
"$here/run.sh" "$arm" "$w" "$pre.prompt" "$pre"
echo "workdir $w"

fail=0
check() { if (cd "$w" && eval "$2") >/dev/null 2>&1; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }
committed() { git log --format= --name-only "$base..HEAD"; }
# a simpleviz server still running in this workdir
own_servers() { for p in $(pgrep -f "simpleviz/bb.edn"); do [ "$(readlink "/proc/$p/cwd")" = "$(pwd -P)" ] && return 0; done; return 1; }
# "<model> <description>" per subagent call
agents() { jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use" and .name=="Agent") | "\(.input.model) \(.input.description)"' "$1.jsonl"; }
tools() { jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use") | "\(.name) \(.input|tostring)"' "$1.jsonl"; }
# edn <file> <get-in path>: prints the value, e.g. edn .blend/modules.edn '[:nodes :app-cache :state]'
edn() { bb -e "(prn (get-in (clojure.edn/read-string (slurp \"$1\")) $2))"; }
# simpleviz check flags missing :pair targets but not :md-ref, so check those here
graphs_ok() { for f in .blend/architecture.edn .blend/modules.edn .blend/intro.md .blend/features.md; do
    [ -f "$f" ] || continue; simpleviz check "$f" | grep -qx ok || return 1; done
  for m in $(grep -ho ':md-ref "[^"]*"' .blend/*.edn | sed 's/:md-ref "\(.*\)"/\1/'); do [ -f ".blend/$m" ] || return 1; done; }
# status <heading>: the Status: value of that features.md section
status() { awk -v h="## $1" '$0==h{f=1;next} /^## /{f=0} f&&/^Status:/{print $2; exit}' .blend/features.md; }
intro_ok() { simpleviz check .blend/intro.md | grep -qx ok && for l in architecture.edn modules.edn features.md; do grep -q "($l)" .blend/intro.md || return 1; done; }

case $name in
  brainstorm)
    check "feature section written, planned" 'h=$(grep -i "^## .*due" .blend/features.md | head -1 | cut -c4-) && [ "$(status "$h")" = planned ]'
    check "feature linked to graphs" 'grep -q ":state :new" .blend/architecture.edn .blend/modules.edn || grep -q "^Touches:.*#" .blend/features.md'
    check "intro links the rest" 'intro_ok'
    check "persist ran first" 'git log --format=%s '"$base"'..HEAD | grep -qx "docs: persist blend graphs"'
    check "existing feature built" 'grep "^Status: built" .blend/features.md'
    check "brainstorm committed" 'git log --format=%s '"$base"'..HEAD | grep -q "^docs: brainstorm"'
    check "no features folder" '[ ! -e .blend/features ]'
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
    check "plan gitignored, not committed, deleted" 'git check-ignore -q .blend/plan.md && git check-ignore -q .blend/plan.edn && ! git log --format= --name-only | grep -q "\.blend/plan\." && [ ! -e .blend/plan.md ] && [ ! -e .blend/plan.edn ]'
    check "plan server stopped" '! own_servers'
    check "plan was markdown" 'tools "'"$pre"'" | grep -q "\.blend/plan\.md"'
    check "no build graphs" '[ ! -e .blend/builds ]'
    check "built commit" 'git log --format=%s '"$base"'..HEAD | grep -q "^blend: built"'
    check "tests pass" 'python3 -m unittest -q'
    check "due date stored and listed" 'd=$(mktemp -d) && cp todo.py "$d" && cd "$d" && python3 todo.py add pay rent --due 2000-01-01 && python3 todo.py list | grep "pay rent" | grep -q "2000-01-01"'
    check "overdue flagged" 'd=$(mktemp -d) && cp todo.py "$d" && cd "$d" && python3 todo.py add pay rent --due 2000-01-01 && python3 todo.py list | grep -q OVERDUE'
    check "future not overdue" 'd=$(mktemp -d) && cp todo.py "$d" && cd "$d" && python3 todo.py add later --due 2999-01-01 && ! python3 todo.py list | grep -q OVERDUE'
    check "bad date rejected" 'd=$(mktemp -d) && cp todo.py "$d" && cd "$d" && ! python3 todo.py add x --due 2000-13-45 && [ "$(python3 todo.py list | wc -l)" -eq 0 ]'
    check "due dates marked built" '[ "$(status "Due dates")" = built ]'
    check "graphs check ok" 'graphs_ok'
    check "reviewer subagent ran" 'tools "'"$pre"'" | grep -qi "^Agent.*review"'
    check "strongest only for plan review or advisor" '! agents "'"$pre"'" | grep "^fable " | grep -vqi "plan\|advis"'
    check "code review on strong" 'agents "'"$pre"'" | grep -i "review" | grep -v -i "plan" | grep -q "^opus "'
    check "every subagent names a model" '[ -z "$(jq -r '"'"'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use" and .name=="Agent") | select(.input.model == null) | .id'"'"' "'"$pre"'.jsonl")" ]'
    check "work committed" '[ -z "$(git status --porcelain --untracked-files=no)" ]' ;;
  build-empty)
    check "no code changed" '[ -z "$(git diff --name-only '"$base"' -- . ":!.blend" ":!.gitignore")" ] && [ -z "$(git status --porcelain --untracked-files=all | grep -v " \.blend/\| \.gitignore$")" ]'
    check "no new build commit" '! git log --format=%s '"$base"'..HEAD | grep -q "^blend: built"' ;;
  persist-merge)
    check "planned module kept" '[ "$(edn .blend/modules.edn "[:nodes :app-cache :state]")" = ":new" ]'
    check "planned component kept" '[ "$(edn .blend/architecture.edn "[:nodes :cache :state]")" = ":new" ]'
    check "persist commit" 'git log --format=%s '"$base"'..HEAD | grep -qx "docs: persist blend graphs"'
    check "new module derived" 'grep -q "app-export" .blend/modules.edn'
    check "planned feature kept" '[ "$(status Cache)" = planned ]'
    check "intro written, links the rest" 'intro_ok'
    check "graphs check ok" 'graphs_ok'
    check "staged file not committed" '! committed | grep -qx notes.txt && git diff --cached --name-only | grep -qx notes.txt'
    check "only .blend committed" '[ -z "$(committed | grep -v "^\.blend/")" ]' ;;
  persist-migrate)
    check "views moved" '[ ! -e .blend/views/modules.edn ] && [ ! -e .blend/views/architecture.edn ] && [ -f .blend/modules.edn ] && [ -f .blend/architecture.edn ]'
    check "system.md removed" '[ ! -e .blend/views/system.md ]'
    check "old plan folder kept" '[ -d .blend/2026-10-09-csv ]'
    check "new module derived" 'grep -q "app-export" .blend/modules.edn'
    check "persist commit" 'git log --format=%s '"$base"'..HEAD | grep -qx "docs: persist blend graphs"'
    check "no marker line" '! grep -rq "persisted-through" .blend/*.edn'
    check "features folder folded in" '[ ! -e .blend/features ] && [ "$(status Reader)" = built ] && ! grep -q "md-ref \"features/" .blend/*.edn'
    check "intro written, links the rest" 'intro_ok'
    check "graphs check ok" 'graphs_ok'
    check "staged file not committed" '! committed | grep -qx notes.txt && git diff --cached --name-only | grep -qx notes.txt'
    check "only .blend committed" '[ -z "$(committed | grep -v "^\.blend/")" ]' ;;
esac
exit $fail

#!/bin/sh
# Usage: BLEND_OLD=<abs 0.6.0 plugins/blend dir> tests/scenarios/outcome/run-outcome.sh <runs-per-arm> <out-dir>
set -u
here=$(cd "$(dirname "$0")" && pwd); n=$1 out=$2
case ${BLEND_OLD:-} in /*) [ -d "$BLEND_OLD" ] || { echo "BLEND_OLD is not a directory" >&2; exit 2; } ;;
  *) echo "set BLEND_OLD to an absolute 0.6.0 plugins/blend dir" >&2; exit 2 ;; esac
mkdir -p "$out"; out=$(cd "$out" && pwd); : > "$out/summary.txt"; sum=$out/summary.txt
printf 'Load blend:brainstorming. Full auto. Build a Python CLI csv2json that converts a CSV file (argument) or stdin to a JSON array of objects on stdout, header row = keys; a missing file exits non-zero with an error message. It must run from the repo root as python3 csv2json.py [file] or python3 -m csv2json [file].\n' > "$out/green.txt"
printf 'Load blend:brainstorming. Full auto. Tasks get an optional due date; overdue tasks are flagged in the API and in the UI.\n' > "$out/brown.txt"

# one <fixture> <setup-fixture> <prompt> <arm> <i>; acceptance command in $acc
one() {
  fx=$1 setup=$2 prompt=$3 arm=$4 i=$5; tag="$fx $arm $i"; pre="$out/$fx-$arm-$i"
  w=$("$here/../setup.sh" "$setup")
  if [ -z "$w" ] || [ ! -d "$w" ]; then echo "$tag ERROR setup failed" >> "$sum"; return; fi
  base=$(git -C "$w" rev-parse HEAD)
  res=$("$here/../run.sh" "$arm" "$w" "$prompt" "$pre")
  [ -n "$res" ] || res="ERROR no result"
  iserr=$(jq -r 'select(.type=="result") | "is_error=\(.is_error)"' "$pre.jsonl" 2>/dev/null | tail -1)
  # score the worktree (main repo included) with most commits beyond the fixture commit
  wt=$w best=-1; all=
  for p in $(git -C "$w" worktree list --porcelain | awk '/^worktree /{sub(/^worktree /,""); print}'); do
    [ -d "$p" ] || continue
    all="$all $p"
    c=$(git -C "$p" rev-list --count "$base..HEAD" 2>/dev/null || echo 0)
    if [ "$c" -gt "$best" ]; then best=$c; wt=$p; fi
  done
  $acc "$wt" > "$pre.acc" 2>&1; rc=$?
  if [ $rc -eq 0 ]; then score=PASS
  else score="FAIL: $(grep -v '^[[:space:]]*$' "$pre.acc" | tail -1 | sed 's/^FAIL:* *//')"; fi
  git -C "$wt" bundle create "$pre.bundle" --all >/dev/null 2>&1 \
    || git -C "$wt" diff "$base" > "$pre.diff" 2>/dev/null
  echo "$tag $res ${iserr:-is_error=?} $score w=$w wt=$wt commits=$best worktrees=[${all# }]" >> "$sum"
}

for arm in old new; do i=1; while [ $i -le "$n" ]; do
  acc="python3 $here/acceptance_csv2json.py"; one green empty "$out/green.txt" $arm $i
  acc="sh $here/acceptance_blackboard.sh";    one brown blackboard "$out/brown.txt" $arm $i
  i=$((i+1)); done; done
cat "$sum"

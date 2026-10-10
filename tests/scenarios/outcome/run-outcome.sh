#!/bin/sh
# Usage: tests/scenarios/outcome/run-outcome.sh <runs-per-arm> <out-dir>
set -u
here=$(cd "$(dirname "$0")" && pwd); n=$1 out=$2; mkdir -p "$out"
printf 'Load blend:brainstorming. Full auto. Build a Python CLI csv2json that converts a CSV file (argument) or stdin to a JSON array of objects on stdout, header row = keys; a missing file exits non-zero with an error message. It must run from the repo root as python3 csv2json.py [file] or python3 -m csv2json [file].\n' > "$out/green.txt"
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

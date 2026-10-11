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

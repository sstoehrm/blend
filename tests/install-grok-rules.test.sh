#!/usr/bin/env sh
# Tests plugins/blend/hooks/install-grok-rules.sh against temporary Grok homes.
set -u
here="$(cd "$(dirname "$0")" && pwd)"
script="$here/../plugins/blend/hooks/install-grok-rules.sh"
skill="$here/../plugins/blend/skills/use-blend/SKILL.md"
fail=0
check() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
out="$tmp/g/rules/blend.md"

# 1. not under Grok: nothing written, silent, exit 0
o=$(GROK_HOME="$tmp/g" sh "$script"); rc=$?
check "outside Grok: exit 0" '[ $rc -eq 0 ]'
check "outside Grok: nothing written" '[ ! -e "$tmp/g" ]'
check "outside Grok: silent" '[ -z "$o" ]'

# 2. under Grok: rules file with use-blend (no frontmatter) and the Grok reference
o=$(GROK_PLUGIN_ROOT=x GROK_HOME="$tmp/g" sh "$script"); rc=$?
check "under Grok: exit 0, silent" '[ $rc -eq 0 ] && [ -z "$o" ]'
check "rules file written" '[ -f "$out" ]'
check "use-blend body included" 'grep -q "^# Use Blend" "$out"'
check "frontmatter stripped" '! grep -q "^name: use-blend" "$out" && ! grep -q "^description:" "$out"'
check "Grok reference included" 'grep -q "^# Blend in Grok" "$out"'

# 3. unchanged content: file not rewritten
touch -d "2000-01-01" "$out"
GROK_PLUGIN_ROOT=x GROK_HOME="$tmp/g" sh "$script"
check "unchanged: not rewritten" '[ "$(date -r "$out" +%Y)" = 2000 ]'

# 4. changed content: rewritten; other rules untouched
echo stale > "$out"; echo mine > "$tmp/g/rules/other.md"
GROK_PLUGIN_ROOT=x GROK_HOME="$tmp/g" sh "$script"
check "stale: rewritten" 'grep -q "^# Use Blend" "$out"'
check "other rules untouched" '[ "$(cat "$tmp/g/rules/other.md")" = mine ]'
check "no temp files left" '[ -z "$(ls -A "$tmp/g/rules" | grep "^\.blend")" ]'

# 5. rules path is a file: no crash
mkdir -p "$tmp/h"; echo keep > "$tmp/h/rules"
GROK_PLUGIN_ROOT=x GROK_HOME="$tmp/h" sh "$script"; rc=$?
check "rules is a file: exit 0, untouched" '[ $rc -eq 0 ] && [ "$(cat "$tmp/h/rules")" = keep ]'
exit $fail

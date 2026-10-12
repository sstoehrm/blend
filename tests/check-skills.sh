#!/usr/bin/env sh
# Checks blend's skills: line budgets, versions, attribution, no stale references.
set -u
cd "$(dirname "$0")/.."
fail=0
bad() { echo "FAIL $1"; fail=1; }
ver=$(jq -r .version plugins/blend/.claude-plugin/plugin.json)
[ "$(jq -r .version plugins/blend/.codex-plugin/plugin.json)" = "$ver" ] || bad "manifest versions differ"
for t in plugins/blend/templates/blend-*.edn; do
  [ "$(head -n 1 "$t")" = ";; blend-template $ver" ] || bad "$t not at $ver"; done
stray=$(grep -rIn -i superpowers plugins/blend .claude-plugin | grep -v -e THIRD_PARTY_NOTICES.md -e ':Adapted from superpowers')
[ -z "$stray" ] || bad "superpowers outside attribution: $stray"
grep -q "Copyright (c) 2025 Jesse Vincent" plugins/blend/THIRD_PARTY_NOTICES.md || bad "MIT notice missing"
for s in use-blend/SKILL.md:70 brainstorming/SKILL.md:60 build/SKILL.md:100 build/reviewer-prompt.md:30 persist/SKILL.md:80; do
  f=plugins/blend/skills/${s%%:*} max=${s##*:}
  [ -f "$f" ] || { bad "$f missing"; continue; }
  n=$(wc -l < "$f"); [ "$n" -le "$max" ] || bad "$f: $n lines > $max"; done
[ "$(ls plugins/blend/skills)" = "$(printf 'brainstorming\nbuild\npersist\nuse-blend')" ] || bad "unexpected skill set: $(ls plugins/blend/skills | tr '\n' ' ')"
for n in planning executing debugging deduce project-views; do
  ! grep -rq "blend:$n\|skills/$n" README.md plugins/blend || bad "blend:$n still referenced"; done
[ -z "$(grep -rnE "features/(<slug>|\*)" README.md plugins/blend | grep -v "persist/SKILL.md:.*features/\*\.md.: one")" ] || bad "per-file feature layout referenced"
! grep -rq "blend-plan-view\|blend-build\b\|\.blend/builds\|builds/YYYY" README.md plugins/blend || bad "old template or build-graph path referenced"
[ $fail -eq 0 ] && echo PASS
exit $fail

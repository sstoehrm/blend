#!/usr/bin/env sh
# Checks blend's skills: line budgets, versions, attribution, no stale references.
set -u
cd "$(dirname "$0")/.." || exit 1
fail=0
bad() { echo "FAIL $1"; fail=1; }
ver=$(jq -r .version plugins/blend/.claude-plugin/plugin.json)
[ "$(jq -r .version plugins/blend/.codex-plugin/plugin.json)" = "$ver" ] || bad "manifest versions differ"
stray=$(grep -rIn -i superpowers plugins/blend .claude-plugin | grep -v -e THIRD_PARTY_NOTICES.md -e ':Adapted from superpowers')
[ -z "$stray" ] || bad "superpowers outside attribution: $stray"
grep -q "Copyright (c) 2025 Jesse Vincent" plugins/blend/THIRD_PARTY_NOTICES.md || bad "MIT notice missing"
for s in use-blend/SKILL.md:70 use-blend/reviewer-prompt.md:30 project-setup/SKILL.md:70 project-setup/references/checklist.md:60 project-setup/references/vuln-gate.md:70 use-blend/references/grok-tools.md:40; do
  f=plugins/blend/skills/${s%%:*} max=${s##*:}
  [ -f "$f" ] || { bad "$f missing"; continue; }
  n=$(wc -l < "$f"); [ "$n" -le "$max" ] || bad "$f: $n lines > $max"; done
# shellcheck disable=SC2012 # skill directory names are plain words
[ "$(ls plugins/blend/skills)" = "$(printf 'project-setup\nuse-blend')" ] || bad "unexpected skill set: $(ls plugins/blend/skills | tr '\n' ' ')"
for n in planning executing debugging deduce project-views brainstorming build persist; do
  ! grep -rq "blend:$n\|skills/$n" README.md plugins/blend || bad "blend:$n still referenced"; done
! grep -rqi "simpleviz\|blend-template\|\.blend/" README.md plugins/blend || bad "simpleviz or .blend/ spec still referenced"
[ $fail -eq 0 ] && echo PASS
exit $fail

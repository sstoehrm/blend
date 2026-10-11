#!/usr/bin/env sh
# Grok Build ignores SessionStart hook output, so the hook that injects
# use-blend in Claude Code does nothing there. Instead write use-blend plus
# blend's Grok reference to Grok's always-loaded rules directory.
# Runs only under Grok (GROK_PLUGIN_ROOT set); rewrites only on change.
# Prints nothing.
[ -n "${GROK_PLUGIN_ROOT:-}" ] || exit 0
root="$(cd "$(dirname "$0")/.." 2>/dev/null && pwd)" || exit 0
dir="${GROK_HOME:-$HOME/.grok}/rules"
mkdir -p "$dir" 2>/dev/null || exit 0
tmp="$dir/.blend.md.$$"
{
  echo "<!-- Written by the blend plugin's SessionStart hook; edits are overwritten. -->"
  # use-blend without its YAML frontmatter
  awk 'NR==1 && /^---$/ {fm=1; next} fm && /^---$/ {fm=0; next} !fm' \
    "$root/skills/use-blend/SKILL.md"
  echo
  cat "$root/skills/use-blend/references/grok-tools.md"
} > "$tmp" 2>/dev/null || { rm -f "$tmp"; exit 0; }
if cmp -s "$tmp" "$dir/blend.md"; then rm -f "$tmp"; else mv "$tmp" "$dir/blend.md"; fi
exit 0

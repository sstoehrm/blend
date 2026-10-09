#!/usr/bin/env sh
# Copy blend's simpleviz templates into simpleviz's templates folder.
# Adds missing ones; replaces one whose first line (;; blend-template
# <version>) differs from blend's. Does nothing without a simpleviz install.
# Prints nothing: SessionStart hook output becomes session context.
src="$(cd "$(dirname "$0")/../templates" 2>/dev/null && pwd)" || exit 0
home="${SIMPLEVIZ_HOME:-$HOME/.simpleviz}"
[ -d "$home" ] || exit 0
[ -e "$home/templates" ] && [ ! -d "$home/templates" ] && exit 0
mkdir -p "$home/templates" 2>/dev/null || exit 0
for f in "$src"/blend-*.edn; do
  [ -f "$f" ] || continue
  dst="$home/templates/$(basename "$f")"
  if [ ! -f "$dst" ] || [ "$(head -n 1 "$f")" != "$(head -n 1 "$dst")" ]; then
    cp "$f" "$dst" 2>/dev/null
  fi
done
exit 0

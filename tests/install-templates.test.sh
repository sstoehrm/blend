#!/usr/bin/env sh
# Tests plugins/blend/hooks/install-templates.sh against temporary homes.
set -u
here="$(cd "$(dirname "$0")" && pwd)"
script="$here/../plugins/blend/hooks/install-templates.sh"
src="$here/../plugins/blend/templates"
fail=0
check() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT

# 1. simpleviz not installed: nothing created, exit 0
SIMPLEVIZ_HOME="$tmp/none" sh "$script"; rc=$?
check "no simpleviz home: exit 0" '[ $rc -eq 0 ]'
check "no simpleviz home: nothing created" '[ ! -e "$tmp/none" ]'

# 2. installed, no templates folder: all three copied
mkdir -p "$tmp/h2"
SIMPLEVIZ_HOME="$tmp/h2" sh "$script"
for t in blend-build blend-architecture blend-modules; do
  check "copies $t" 'cmp -s "$src/$t.edn" "$tmp/h2/templates/$t.edn"'
done

check "silent" '[ -z "$(SIMPLEVIZ_HOME=$tmp/h2 sh "$script")" ]'

# 3. same version, edited by the user: kept
printf '\n;; my edit\n' >> "$tmp/h2/templates/blend-build.edn"
SIMPLEVIZ_HOME="$tmp/h2" sh "$script"
check "same version edit kept" 'grep -q "my edit" "$tmp/h2/templates/blend-build.edn"'

# 4. other version: replaced
printf ';; blend-template 0.0.1\n{}\n' > "$tmp/h2/templates/blend-modules.edn"
SIMPLEVIZ_HOME="$tmp/h2" sh "$script"
check "other version replaced" 'cmp -s "$src/blend-modules.edn" "$tmp/h2/templates/blend-modules.edn"'

# 5. templates is a file: no crash, exit 0, file untouched
mkdir -p "$tmp/h5"; echo keep > "$tmp/h5/templates"
SIMPLEVIZ_HOME="$tmp/h5" sh "$script"; rc=$?
check "templates file: exit 0" '[ $rc -eq 0 ]'
check "templates file: untouched" '[ "$(cat "$tmp/h5/templates")" = keep ]'

# 6. user templates survive
mkdir -p "$tmp/h6/templates"; echo '{}' > "$tmp/h6/templates/web.edn"
SIMPLEVIZ_HOME="$tmp/h6" sh "$script"
check "user template kept" '[ "$(cat "$tmp/h6/templates/web.edn")" = "{}" ]'

# 7. every template parses and checks clean
for t in "$src"/blend-*.edn; do
  check "simpleviz check $(basename "$t")" 'simpleviz check "$t" >/dev/null'
done

# 8. every template starts with the version line
for t in "$src"/blend-*.edn; do
  check "version line $(basename "$t")" '[ "$(head -n 1 "$t")" = ";; blend-template 0.8.0" ]'
done
exit $fail

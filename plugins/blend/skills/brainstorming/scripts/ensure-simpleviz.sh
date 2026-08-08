#!/usr/bin/env bash
# Ensures the latest simpleviz release is available next to this script.
# Prints the simpleviz directory on success. Requires: gh (authenticated
# for sstoehrm/simpleviz), tar. Delete the simpleviz/ dir to re-download.
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dest="$dir/simpleviz"

if [ ! -f "$dest/bb.edn" ]; then
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  gh release download -R sstoehrm/simpleviz --pattern 'simpleviz-*.tar.gz' --dir "$tmp" >&2
  rm -rf "$dest"
  mkdir -p "$dest"
  tar xzf "$tmp"/simpleviz-*.tar.gz -C "$dest" --strip-components=1
fi

echo "$dest"

#!/bin/sh
# Copy a scenario fixture into a fresh temp git repo; print its path.
# Usage: tests/scenarios/setup.sh <fixture>   (a dir under fixtures/, or blackboard, or empty)
set -eu
here=$(cd "$(dirname "$0")" && pwd)
d=$(mktemp -d)
case $1 in
  blackboard) git clone -q "${BLACKBOARD_REPO:-$HOME/repos/private/smpl-blackboard}" "$d/repo"
              echo "$d/repo"; exit 0 ;;
  empty) ;;
  *) [ -d "$here/fixtures/$1" ] || { echo "no fixture $1" >&2; exit 2; }
     cp -R "$here/fixtures/$1/." "$d/" ;;
esac
cd "$d"
git init -q
git add -A
git -c user.name=fixture -c user.email=fixture@example.com commit -q --allow-empty -m fixture
echo "$d"

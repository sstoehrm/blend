set -e
cd "$1"
bb test
grep -rqi "due" src
grep -rqi "overdue" src
grep -rqi "overdue" public
echo PASS

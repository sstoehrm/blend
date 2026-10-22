#!/bin/sh
cd "$1" || { echo "FAIL no such dir"; exit 1; }
bb test || { echo "FAIL bb test"; exit 1; }
grep -rqi "due" src || { echo "FAIL no 'due' in src"; exit 1; }
grep -rqi "overdue" src || { echo "FAIL no 'overdue' in src"; exit 1; }
grep -rqi "overdue" public || { echo "FAIL no 'overdue' in public"; exit 1; }
echo PASS

---
name: debugging
description: Use when facing a bug, a failing test, a crash, or behavior that differs from what's expected — before proposing a fix.
---

# Debugging (blend)

No fix without a root cause. A change that makes the symptom go away
without explaining it hides the bug.

## 1. Reproduce

Run the failing command or test yourself and read the whole error:
message, stack trace, file and line. If it doesn't reproduce, collect
data (inputs, logs, environment) before guessing.

## 2. Check what changed

`git log` and `git diff` around the failing code; recent dependency,
config or environment changes.

## 3. Trace to the cause

Follow the bad value back through the call chain to where it first goes
wrong. Across components (CLI → service → store), log what enters and
leaves each boundary once, run once, and see where it breaks. Compare
with similar code that works.

## 4. One hypothesis at a time

State it ("X is empty because Y returns early when Z"), make the
smallest change or measurement that tests it, run it. Wrong: form a new
one from what you learned. Never stack fixes.

## 5. Fix

1. Write a test that fails because of the bug (use-blend's TDD rules).
2. Fix the cause in one change.
3. Run that test and the suite; show the output.

## Three failed fixes: stop

When three fixes failed, or each fix surfaces a new problem elsewhere,
the design is the problem. Stop, tell the user what you tried and what it
showed, and discuss the structure before a fourth attempt.

Adapted from superpowers:systematic-debugging by Jesse Vincent (MIT).

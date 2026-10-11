---
name: build
description: Use when a feature should be implemented with blend — from .blend feature files or a plain request — planning and executing in one full-auto run on a branch, ending with a review and updated graphs.
---

# Build (blend)

Plans and implements in one run, without stopping to ask. Input: one or
more `.blend/features/*.md`, or a plain request. **REQUIRED SUB-SKILL:**
simpleviz:simpleviz for the EDN format.

Stop and ask only for destructive or security-sensitive actions, side
effects outside the repo (push, publish, installs outside the project),
or a feature so unclear that every path is a guess. Everything else:
decide, and note it.

## 1. Set up

1. **Branch** first — nothing is committed on the default branch. Not
   on it: stay on the current branch. On it: `git switch -c <slug>`
   (uncommitted `.blend/` changes come along). Uncommitted changes
   outside `.blend/`, or the user asked: `git worktree add
   ../<repo>-<slug> -b <slug>`, copy `.blend/` changes over, work there.
2. Plain request: write a short `.blend/features/<slug>.md` (intent,
   behaviour, decisions you made). Commit `.blend/` with a pathspec.
3. `.blend/views/` exists: run blend:persist to migrate it.
4. Read the feature files, the graph nodes they touch (`:state :new`
   ones, `Touches:` lines), the code around them; run the test suite
   (already red: note it, go on).

## 2. Plan

Write `.blend/builds/<YYYY-MM-DD>-<slug>.edn`: one node per task —
`:tN {:name "N. <title>" :type "task" :state :new :text "<one-line brief>"}` —
and `[:tA :tB] {:direction :-> :type "needs"}` when B needs A. A task is
one test cycle that could be reviewed on its own; one task is fine.
`simpleviz init <file> -t blend-build` is a shortcut. Commit it.

Resume: a branch `<slug>` or a `builds/*-<slug>.edn` exists → switch to
it; `:done` tasks are done (`git log` confirms); continue at the first
that isn't.

## 3. Implement

Take tasks in order, one at a time:

1. Set `:state :in-progress`.
2. TDD: failing test, see it fail, minimal code, see it pass. Run the
   suite.
3. Set `:state :done`; commit code and build graph together.

Many tasks or a large codebase: a subagent per task may do steps 2–3,
one at a time, with the feature file and the task's `:text`.

A task that can't pass as planned: change the plan (edit, split or add
tasks) rather than forcing it. Every decision the feature file didn't
settle goes in the feature file under `## Build notes`: `- <decision> —
<why>`.

## 4. Finish

Every build, one task or ten:

1. **Review** — one reviewer subagent with `reviewer-prompt.md`, the
   feature files and the range since the build started. Fix what holds
   in one pass; the reviewer re-checks only those findings. Only a host
   without a subagent tool reviews inline (say so).
2. **Graphs** — `.blend/architecture.edn` or `modules.edn` exists: load
   blend:persist with source git (it clears `:state :new` on what now
   exists). Neither exists: skip, and offer persist in the report.
3. **Suite** — run it and show the output.
4. **Report** — what was built, the build notes, the review result, the
   branch. Keep the branch: no merge or push unless the user asks.

Adapted from superpowers:subagent-driven-development and executing-plans
by Jesse Vincent (MIT).

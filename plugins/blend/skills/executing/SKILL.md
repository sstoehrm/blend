---
name: executing
description: Use when a blend plan graph (.blend/<date>-<topic>.edn with task nodes and task files) is approved and should be implemented.
---

# Executing (blend)

Runs a blend plan. The plan graph gives the order, each task file is the
task's brief, overview.md gives the goal, constraints and review focus.

## Setup

1. Read overview.md and the plan graph. Read task files only when their
   task starts.
2. Don't work on the default branch. If you are on it, create a worktree
   — `git worktree add ../<repo>-<topic> -b <topic>` (or the repo's
   `.worktrees/` if it has one) — and work there. Ask first, except under
   full auto.
3. Run the test suite. Failing before you start: report and ask (full
   auto: log it and continue).
4. Resume: `:state :done` tasks are done; `git log` confirms.
5. Mode: inline, unless the user asked for subagents or the plan has
   5+ tasks and the host has a subagent tool. Say which.

A task is ready when every task with a `needs` edge into it is `:done`.
Take ready tasks in number order, one at a time.

## Inline

Per task:

1. Set its node's `:state :in-progress`.
2. Read its task file and the views its node `:pair`s or `:ref`s.
3. Follow the steps in order — failing test, see it fail, implement, see
   it pass — and commit as the task says.
4. Run the full suite.
5. Set `:state :done`; commit the plan graph (`chore(plan): task N done`).

Blocked (missing information, a wrong plan, a test that can't pass): set
`:state :blocked :reason "<why>"` and ask. Full auto: decide, log, go on.

## Subagent per task

Per task, one at a time — parallel implementers collide:

1. BASE = `git rev-parse HEAD`; set `:in-progress`.
2. Implementer subagent: the task file path ("your requirements; use
   its exact values"), overview.md's Global constraints, names earlier
   tasks produced that it can't know, and: "Don't dispatch subagents.
   Follow the steps with TDD and commit. Report status (done, done with
   concerns, blocked, needs context), commits, test summary, concerns."
   Mid-tier model; the cheapest when the task file holds complete code.
3. Blocked or needs context: add context, use a stronger model, or split
   the task. Never re-dispatch unchanged.
4. Reviewer subagent: `reviewer-prompt.md`, the task file, the range
   `BASE..HEAD`. Mid-tier model at least.
5. Findings: the implementer fixes, the reviewer re-checks those
   findings only. Still open after 2 rounds: decide each (fix it
   yourself, accept, or park it), log it, go on.
6. Set `:done`; commit the plan graph. Every task gets its reviewer,
   the last one too; never mark `:done` before its review.

## Execution log

Decisions made while executing — a plan conflict, a parked finding, a
full-auto choice — go to overview.md `## Execution log` as
`- Task N: <decision> — <why>`. The graph's `:state` and this log are
how a later session resumes.

## Finish

Every step runs, in either mode and under full auto, whatever the plan's
size. Don't copy views by hand — blend:persist does that.

1. Whole-branch review: one reviewer, most capable model,
   `reviewer-prompt.md`, overview.md, the range from the branch base.
   One fix pass, one re-check.
2. Load blend:persist with source plan.
3. Run the full suite and show its output.
4. Offer: (1) merge into `<base>` locally, (2) push and open a PR,
   (3) keep the branch. Wait for the choice; full auto keeps it.
   - Merge: merge, run the suite on the result, then delete the branch
     and remove the worktree if you created it.
   - PR: `git push -u origin <branch>`, `gh pr create`; keep the worktree.

Never force-push, merge on a red suite, or delete unmerged work without
the user typing the confirmation.

Adapted from superpowers:subagent-driven-development, executing-plans,
using-git-worktrees and finishing-a-development-branch by Jesse Vincent
(MIT).

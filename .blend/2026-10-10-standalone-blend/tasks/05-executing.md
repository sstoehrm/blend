# Task 5: blend:executing and the reviewer prompt

**Goal:** run a blend plan graph — inline or one subagent per task —
then review, persist, verify and finish, without superpowers.

**Files:**
- Create: `plugins/blend/skills/executing/SKILL.md`
- Create: `plugins/blend/skills/executing/reviewer-prompt.md`

**Interfaces:**
- Consumes: `blend:persist` source `plan` (task 3); plan graph format
  (task nodes `:state`, `needs` edges, `:md-ref` task files) from
  blend:planning; `run.sh`, `setup.sh` (task 1).
- Produces: `blend:executing`; `reviewer-prompt.md` (named by use-blend);
  overview.md section `## Execution log`.

- [ ] **Step 1: Write the scenarios**

Prompts start: `Load the skill blend:executing and follow it. Full auto:
do not ask questions; decide, log decisions, and keep the branch at the
end.`

| # | Fixture | Rest of the prompt | Pass |
| --- | --- | --- | --- |
| S5 | `csv-plan` | `Execute the plan .blend/2026-10-09-csv-to-json.edn inline.` | work happens off the default branch (a worktree or branch); every task node `:state :done`; one or more commits per task; tests pass at the end (output shown); a `docs: persist project views` commit; finish = keep, no merge, no push |
| S5b | S5's result repo, `git reset --hard` to its `chore(plan): task 1 done` commit (in the worktree S5 used) | `Resume executing the plan .blend/2026-10-09-csv-to-json.edn inline.` | says it resumes at task 2; does not touch task 1's files except where task 2 says; ends like S5 |
| S6 | `csv-plan` | `Execute the plan .blend/2026-10-09-csv-to-json.edn with one subagent per task.` | one implementer and one reviewer Agent call per task, never two implementers at once; one whole-branch review at the end; otherwise as S5 |

- [ ] **Step 2: Run the baseline**

S5 with arm `old`, prompt `Execute the plan .blend/2026-10-09-csv-to-json.edn.
Full auto: do not ask questions.` Record the summary line, whether it
used superpowers' scripts, and whether it synced the views.

- [ ] **Step 3: Write SKILL.md**

````markdown
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
6. Set `:done`; commit the plan graph.

## Execution log

Decisions made while executing — a plan conflict, a parked finding, a
full-auto choice — go to overview.md `## Execution log` as
`- Task N: <decision> — <why>`. The graph's `:state` and this log are
how a later session resumes.

## Finish

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
````

- [ ] **Step 4: Write reviewer-prompt.md**

````markdown
# Reviewer prompt (blend)

You review one change. Read only: don't edit files, don't dispatch
subagents.

Inputs: the requirements (a task file or overview.md), the change (a
commit range or a diff file), the repository.

Check, in order:

1. **Requirements** — everything required is there, nothing unrequested
   was added, exact values (names, paths, numbers, messages) match.
2. **Correctness** — logic errors, edge cases the requirements imply,
   error handling at trust boundaries, data loss.
3. **Tests** — they fail without the change and test behavior, not
   mocks; review-focus items this change owns have a test.
4. **Regressions** — read the callers and neighbors of changed code.
5. **Security** — concrete issues only: injection, secrets, missing auth.
6. **Complexity** — unneeded code, duplication, one-use abstractions.

Report:

- Verdict: approve, approve with fixes, or reject.
- Findings, most severe first:
  `[critical|important|minor] file:line — what is wrong — evidence — fix`.
- An area with no findings: "none".

Style preferences are not findings. Report only what you verified in
the code.

Adapted from superpowers:requesting-code-review (code-reviewer.md) by
Jesse Vincent (MIT).
````

- [ ] **Step 5: Run the scenarios**

S5, S5b, S6 with arm `new`. Expected: the pass column, `superpowers_uses=0`.
`wc -l`: SKILL.md ≤ 150, reviewer-prompt.md ≤ 60.

- [ ] **Step 6: Commit**

```sh
git add plugins/blend/skills/executing
git commit -m "feat: blend:executing runs plan graphs inline or per-task subagents"
```

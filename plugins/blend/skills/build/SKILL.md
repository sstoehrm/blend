---
name: build
description: Use when blend's spec (.blend features, architecture and module graphs) has changed and the code should catch up — or for a plain feature request — planning and implementing in one full-auto run on a branch.
---

# Build (blend)

`.blend/` is the spec: `features/*.md`, `architecture.edn`, `modules.edn`.
Build implements what changed in it since the last build, without
stopping to ask. **REQUIRED SUB-SKILL:** simpleviz:simpleviz.

Stop and ask only for destructive or security-sensitive actions, side
effects outside the repo (push, publish, installs), or a spec so unclear
that every path is a guess. Everything else: decide, and note it.

## 1. Branch

Nothing is committed on the default branch. Not on it: stay on the
current branch. On it: `git switch -c <slug>` (uncommitted `.blend/`
changes come along). Uncommitted changes outside `.blend/`, or the user
asked: `git worktree add ../<repo>-<slug> -b <slug>`, copy `.blend/`
changes over, work there. `.blend/views/` exists: run blend:persist to
migrate it.

## 2. Spec

- Plain request: write it into `.blend/features/<slug>.md` first (intent,
  behaviour, decisions you made) — it becomes part of the diff.
- Base = `git log -1 --grep='^blend: built' --format=%H`. The spec is
  `git diff <base> -- .blend` (uncommitted changes included). Read the
  feature files it touches in full, for context.
- No base (first build, or a squash merge dropped the commit): the spec
  is everything in `.blend/` the code doesn't do yet — `:state :new`
  nodes and features you check against the code.
- Empty spec: say so and stop.

## 3. Plan

`.blend/plan.edn` — local, never committed: make sure `.gitignore` lists
`.blend/plan.edn` (add the line and commit `.gitignore` if not). One
node per task, `:tN {:name "N. <title>" :type "task" :state :new :text
"<one-line brief>"}`, and `[:tA :tB] {:direction :-> :type "needs"}`
when B needs A. A task is one test cycle that could be reviewed alone;
one task is fine. Template: `simpleviz init .blend/plan.edn -t blend-plan`.

Resume: `.blend/plan.edn` exists → `:done` tasks are done (`git log`
confirms); go on from the first that isn't. A build branch without a
plan: plan again from the spec, minus what the branch already did.

## 4. Implement

Tasks in order, one at a time: set `:state :in-progress`; TDD — failing
test, see it fail, minimal code, see it pass; run the suite; commit;
set `:state :done`. Large builds: a subagent per task may do the TDD and
commit, one at a time, given the feature file and the task's `:text`.

A task that can't pass as planned: change the plan rather than forcing
it. Decisions the spec didn't settle go in the feature file under
`## Build notes`: `- <decision> — <why>`.

## 5. Finish

Every build, one task or ten:

1. **Review** — one reviewer subagent with `reviewer-prompt.md`, the
   spec diff and the range since the build started. Fix what holds in
   one pass; the reviewer re-checks only those findings. Only a host
   without a subagent tool reviews inline (say so).
2. **Graphs** — the build built `:state :new` nodes or added, removed
   or rewired modules or components: load blend:persist with source git.
   Otherwise say the graphs still match; a later persist catches up.
3. **Suite** — run it and show the output.
4. **Sync** — commit any `.blend/` changes, then
   `git commit --allow-empty -m "blend: built <slug>"` (the next build's
   base); delete `.blend/plan.edn`.
5. **Report** — what was built, the build notes, the review result, the
   branch. Keep the branch: no merge or push unless the user asks.

Adapted from superpowers:subagent-driven-development and executing-plans
by Jesse Vincent (MIT).

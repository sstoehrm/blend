---
name: build
description: Use when blend's spec (.blend features, architecture and module graphs) has changed and the code should catch up — or for a plain feature request — planning and implementing in one full-auto run on a branch.
---

# Build (blend)

`.blend/` is the spec: `features/*.md`, `architecture.edn`, `modules.edn`.
Build implements what changed in it since the last build, without
stopping to ask — except for destructive or security-sensitive actions,
side effects outside the repo (push, publish, installs), or a spec so
unclear that every path is a guess. **REQUIRED SUB-SKILL:**
simpleviz:simpleviz.

## 1. Branch

Never commit on the default branch: on it, `git switch -c <slug>`
(uncommitted `.blend/` changes come along); otherwise stay. Uncommitted
changes outside `.blend/`, or the user asked: `git worktree add
../<repo>-<slug> -b <slug>`, copy `.blend/` changes over, work there.
`.blend/views/` exists: run blend:persist to migrate it.

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

`.blend/plan.md` — local, never committed (`.gitignore` lists
`.blend/plan.*`; add and commit the line if missing). Markdown that
simpleviz serves, linking into the spec:

- **Spec** — links to what the diff touches: `[x](features/x.md)`, `[architecture](architecture.edn)`.
- **Tasks** — `- [ ] N. <title> — <brief>`, in order; each one test cycle.
- Not a straight line: also `.blend/plan.edn` (`-t blend-plan`), linked.

`simpleviz check .blend/plan.md` is clean. Serve it, keeping the PID:
`simpleviz .blend/plan.md --no-open > .blend/plan.log 2>&1 & echo $!`;
give the URL from plan.log.

Resume: `[x]` tasks in plan.md are done (`git log` confirms). No plan on
a build branch: plan again from the spec, minus what the branch did.

## 4. Implement

Tasks in order, one at a time: TDD — failing test, see it fail, minimal
code, see it pass; run the suite; commit; tick it `[x]` (and its
`:state`). Large builds: one subagent per task, never two at once, with
the feature file and the task line. A task that can't pass as planned:
change the plan. Decisions the spec didn't settle: feature file,
`## Build notes`, `- <decision> — <why>`.

## Subagent models

Always name the model (unnamed inherits the session's): cheapest (Haiku),
mid (Sonnet), strong (Opus), strongest (Fable, only when asked).

| Role | Tier |
| --- | --- |
| Exploration, search | cheapest |
| Implementer, the task line names the exact change | cheapest |
| Implementer, needs judgement or touches several files | mid |
| Reviewer | mid; strong for large or risky diffs (security, data, concurrency) |

## 5. Finish

Every build, one task or ten:

1. **Review** — one reviewer subagent (model per the table) with
   `reviewer-prompt.md`, the spec diff and the range since the build
   started. Fix what holds in one pass; the reviewer re-checks only those
   findings. Only a host without a subagent tool reviews inline (say so).
2. **Graphs** — the build built `:state :new` nodes or added, removed
   or rewired modules or components: load blend:persist with source git.
   Otherwise say the graphs still match; a later persist catches up.
3. **Suite** — run it and show the output.
4. **Sync** — commit `.blend/` changes, then `git commit --allow-empty
   -m "blend: built <slug>"` (the next base); `kill <PID>` — never by
   pattern; delete `.blend/plan.*`.
5. **Report** — what was built, build notes, review result, branch. No
   merge or push unless the user asks.

Adapted from superpowers:subagent-driven-development and executing-plans
by Jesse Vincent (MIT).

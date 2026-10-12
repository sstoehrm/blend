---
name: build
description: Use when blend's spec (.blend/features.md, architecture and module graphs) has changed and the code should catch up — or for a plain feature request — planning and implementing in one full-auto run on a branch.
---

# Build (blend)

`.blend/` is the spec: `features.md`, `architecture.edn`, `modules.edn`.
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
`.blend/views/` or `.blend/features/` exists: run blend:persist to migrate.

## 2. Spec

- Plain request: first add it to `.blend/features.md` as `## <Name>`,
  `Status: planned`, intent, behaviour, decisions — part of the diff.
- Base = `git log -1 --grep='^blend: built' --format=%H`. The spec is
  `git diff <base> -- .blend/features.md .blend/architecture.edn
  .blend/modules.edn` (uncommitted included; `Status: built` sections
  are not spec). Read the sections it touches in full.
- No base (first build, or a squash merge dropped the commit): the spec
  is what the code doesn't do yet — `:state :new` nodes, planned features.
- Empty spec: say so and stop.

## 3. Plan

`.blend/plan.md` — local, never committed (`.gitignore` lists
`.blend/plan.*`; add and commit the line if missing). Markdown that
simpleviz serves, linking into the spec:

- **Spec** — links to what the diff touches: `[features](features.md)`, `[architecture](architecture.edn)`.
- **Tasks** — `- [ ] N. <title> — <brief>`, in order; each one test cycle.
- Not a straight line: also `.blend/plan.edn` (`-t blend-plan`), linked.

`simpleviz check .blend/plan.md` is clean. Serve it, keeping the PID:
`simpleviz .blend/plan.md --no-open > .blend/plan.log 2>&1 & echo $!`;
give the URL from plan.log.

**Plan review** — 3+ tasks, or a change hard to undo (data format,
public interface, migration): one subagent (strongest) checks plan.md
against the spec diff — missing or unrequested work, wrong order, tasks
no test can check. Fix what holds; no second round. Smaller: skip, say so.

Resume: `[x]` tasks in plan.md are done (`git log` confirms). No plan on
a build branch: plan again from the spec, minus what the branch did.

## 4. Implement

Tasks in order, one at a time: TDD — failing test, see it fail, minimal
code, see it pass; run the suite; commit; tick it `[x]` (and its
`:state`). Large builds: one subagent per task, never two at once, with
the feature section and the task line. A task that can't pass as planned:
change the plan. Stuck after two failed attempts, or a decision that is
hard to undo: ask an advisor subagent (strongest) with the plan, the spec
and what you tried. Decisions the spec didn't settle: in the feature's
section, `### Build notes`, `- <decision> — <why>`.

## Subagent models

Always name the model (unnamed inherits the session's). Tiers today:
cheapest (Haiku), mid (Sonnet), strong (Opus), strongest (Fable).

| Role | Tier |
| --- | --- |
| Exploration, search | cheapest |
| Implementer, simple: the task line names the exact change | mid |
| Implementer, needs judgement or touches several files | strong |
| Reviewer | strong |
| Plan review, advisor | strongest |

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
4. **Sync** — sections built get `Status: built`; commit `.blend/`,
   then `git commit --allow-empty -m "blend: built <slug>"` (the next
   base); `kill <PID>` — never by pattern; delete `.blend/plan.*`.
5. **Report** — what was built, build notes, review result, branch. No
   merge or push unless the user asks.

Adapted from superpowers:subagent-driven-development and executing-plans
by Jesse Vincent (MIT).

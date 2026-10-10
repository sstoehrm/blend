# Task 6: blend:planning without superpowers

**Goal:** planning carries the writing-plans rules it needs inline and
hands off to blend:executing.

**Files:**
- Modify: `plugins/blend/skills/planning/SKILL.md` (full rewrite below)

**Interfaces:**
- Consumes: `blend:executing` (task 5), `blend:persist` source `plan`
  (task 3) — by name only; `run.sh`, `setup.sh` (task 1).
- Produces: the same plan format as 0.6.0 (task nodes, `needs` edges,
  task files, overview sections `## Plan`, `## Global constraints`,
  `## Review focus`, `## Executing this plan`).

- [ ] **Step 1: Write the scenario**

S4, fixture `csv-design`, prompt:

```
Load the skill blend:planning and follow it. The design in
.blend/2026-10-09-csv-to-json* is approved. Write the plan. Do not ask
questions; stop at the hand-off message.
```

Pass: ≥ 2 task nodes with `:type "task"`, `:state :new`, `:md-ref` to
existing task files, `:pair` into the slices; `needs` edges without a
cycle; each task file starts `# Task N:` and has Goal, Files, Interfaces
and checkbox steps with code; overview.md gained the four sections and
its `## Executing this plan` names blend:executing and blend:persist;
module-slice elements carry `:tasks`; files clean via `/api/errors`; no
`docs/superpowers/` file; `superpowers_uses=0`; the hand-off names the
plan graph and offers inline or subagent-per-task.

- [ ] **Step 2: Run the baseline**

S4 with arm `new` against the 0.6.0 skill (before Step 3). Expected: it
tries to load superpowers:writing-plans, fails or improvises
(`superpowers_uses` ≥ 1 or a note that it is missing). Record it.

- [ ] **Step 3: Rewrite SKILL.md**

````markdown
---
name: planning
description: Use when a blend design (.blend/<date>-<topic>.edn with overview.md and plan views) is approved and needs an implementation plan.
---

# Planning (blend)

Turns an approved blend design into a plan: task nodes in the plan graph,
one task file per task, and plan notes in overview.md.
**REQUIRED SUB-SKILL:** simpleviz:simpleviz. `<plan>` = the design's
`YYYY-MM-DD-<topic>`.

## Before the tasks

- Scope: a design with independent subsystems gets one plan per
  subsystem; say so and plan the first.
- File structure: list the files to create or modify and what each is
  responsible for. One responsibility per file; follow the repo's
  patterns.

## Tasks

A task is the smallest unit with its own test cycle that a reviewer
could reject on its own. Fold setup, configuration and docs into the
task that needs them.

`.blend/<plan>/tasks/NN-<slug>.md`:

- `# Task N: <title>`, then **Goal** (one sentence).
- **Files**: Create / Modify (with line ranges) / Test, exact paths.
- **Interfaces**: Consumes and Produces — exact names, signatures and
  types other tasks rely on; an implementer sees only this file.
- Checkbox steps, one action each (2–5 minutes): write the failing test
  (the code) → run it, expected failure → minimal implementation (the
  code) → run it, expected pass → commit (the command).

No placeholders: no "TBD", "add error handling", "similar to task N" or
"write tests for the above". Every code step shows the code; every name
a task uses is defined in some task.

| Plan part | Where |
| --- | --- |
| Goal, architecture, decisions | already in overview.md — don't repeat |
| Tech stack | overview.md `## Plan` |
| Global constraints (versions, naming, limits; exact values) | overview.md `## Global constraints` |
| Review focus | overview.md `## Review focus`; each line's test in the owning task file |
| Task order | edges in the plan graph |

Review focus: up to five inputs or failure modes the design implies but
no test exercises, most likely first, each with the behavior a user
would expect.

## Plan graph

In `.blend/<plan>.edn`, per task:

- node `:tNN {:name "N. <title>" :type "task" :state :new
  :md-ref "<plan>/tasks/NN-<slug>.md" :pair [...]}`; `:pair` names the
  plan-slice elements the task builds: `"<plan>/modules.edn#<id>"`,
  `"<plan>/architecture.edn#<id>"`.
- `:ref "<plan>/<view>.edn"` when the task needs a view no slice shows (a
  migration flow, a folder layout), in the plan-view shape.
- edge `[:tA :tB] {:direction :-> :type "needs"}` only when B cannot start
  before A is done. A needless edge hides parallel work.
- box tasks by the architecture component they mainly build
  (`:type "component"`).

In the modules slice, set `:tasks ["N. <title>" …]` on each element a
task touches. Every `new`, `changed` or `removed` slice element is
touched by a task; every task pairs to at least one element.

## Executing this plan

Write into overview.md, paths filled in (replace an existing section):

```markdown
## Executing this plan

Plan graph: `.blend/<plan>.edn`. Run it with blend:executing. Without
blend: task order follows the graph's `needs` edges; tasks without a path
between them are independent. Each task's brief is its task file plus
this overview and the views its node links to. Set the task node's
`:state`: `:in-progress` when started, `:done` once reviewed,
`:blocked` with `:reason "<why>"`. After the last task, update
`.blend/views/` (blend:persist, source plan).
```

## Self-review

Every design requirement maps to a task; names and signatures match
across tasks; no placeholders; the edges have no cycle; every task file
exists and its title matches its node; every file is clean from the
served plan graph (`curl -s "$URL/api/errors?file=<path>"`). Fix inline,
then commit the plan graph, task files, slices and overview.md together.

## Hand-off

Give the plan graph URL and `.blend/<plan>/tasks/`; ask the user to
review and to pick inline or subagent-per-task, then load
blend:executing. blend:brainstorming's involvement level decides whether
you stop here.

Adapted from superpowers:writing-plans by Jesse Vincent (MIT).
````

- [ ] **Step 4: Run the scenario**

S4 with arm `new`. Expected: the pass criteria. `wc -l` ≤ 120;
`grep -i superpowers` finds only the "Adapted from" line.

- [ ] **Step 5: Commit**

```sh
git add plugins/blend/skills/planning
git commit -m "feat: blend:planning carries its own rules, hands off to blend:executing"
```

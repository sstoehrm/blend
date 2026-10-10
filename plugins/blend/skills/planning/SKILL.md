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

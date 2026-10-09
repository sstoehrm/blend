---
name: planning
description: Use when a blend design (.blend/<date>-<topic>.edn with overview.md and plan views) is approved and needs an implementation plan — use instead of superpowers:writing-plans.
---

# Planning (blend)

Turns an approved blend design into a plan: task nodes in the plan graph,
one task file per task, and plan notes in overview.md.

**REQUIRED BACKGROUND:** superpowers:writing-plans — load it and follow
its rules for scope check, file structure, task right-sizing, bite-sized
TDD steps, task structure (Files, Interfaces, checkbox steps with code),
no placeholders, and self-review. Ignore its save location, plan document
and header; the table below says where each part goes.
**REQUIRED SUB-SKILL:** simpleviz:simpleviz.

`<plan>` = the design's `YYYY-MM-DD-<topic>`.

| writing-plans part | Here |
| --- | --- |
| Goal, Architecture, Spec | already in overview.md — don't repeat |
| Tech Stack | overview.md `## Plan` |
| Global Constraints | overview.md `## Global constraints` |
| Review Focus | overview.md `## Review focus`; each line's test in the owning task file |
| `### Task N` | `.blend/<plan>/tasks/NN-<slug>.md`, starting `# Task N: <title>` |
| Task order | edges in the plan graph |

## Plan graph

In `.blend/<plan>.edn`, per task:

- node `:tNN {:name "N. <title>" :type "task" :state :new
  :md-ref "<plan>/tasks/NN-<slug>.md" :pair [...]}`; `:pair` names the
  plan-slice elements the task builds: `"<plan>/modules.edn#<id>"`,
  `"<plan>/architecture.edn#<id>"`.
- `:ref "<plan>/<view>.edn"` when the task needs a view no slice shows (a
  migration flow, a folder layout) — draw it with `-t blend-plan-view`.
- edge `[:tA :tB] {:direction :-> :type "needs"}` only when B cannot start
  before A is done. A needless edge hides parallel work.
- box tasks by the architecture component they mainly build
  (`:type "component"`).

In the modules slice, set `:tasks ["N. <title>" …]` on each element a
task touches. Every `new`, `changed` or `removed` slice element is touched
by a task; every task pairs to at least one element.

## Executing this plan

Append to overview.md, paths filled in (replace an existing `## Executing this plan` section instead of adding a second):

```markdown
## Executing this plan

Plan graph: `.blend/<plan>.edn`. Use superpowers:subagent-driven-development
or superpowers:executing-plans. Task order follows the graph's edges;
tasks without a path between them are independent. Each task's brief is
its task file plus this overview and the views its node links to. Set the
task node's `:state` as you go: `:in-progress` when started, `:done` once
its review is clean, `:blocked` with `:reason "<why>"`. After the last
task, load blend:project-views and run its "Sync after implementation"
against this plan.
```

## Self-review

writing-plans' checklist, against overview.md and the plan views, plus:
the edges have no cycle; every task file exists and its title matches its
node; every file is clean when checked from the plan graph (served:
`curl -s "$URL/api/errors?file=<path>"`). Fix inline, then commit the plan
graph, the task files, the slices and overview.md together.

## Hand-off

writing-plans' execution hand-off, naming the plan graph URL and
`.blend/<plan>/tasks/` instead of a plan file. blend:brainstorming's
involvement level decides whether you stop for it.

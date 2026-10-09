# Task 5: blend:planning skill

**Goal:** a skill that turns an approved blend design into a plan: task
nodes and edges in the plan graph, one task file per task, plan notes in
overview.md — following superpowers:writing-plans' rules for task content.

**Files:**
- Create: `plugins/blend/skills/planning/SKILL.md`

**Interfaces:**
- Consumes: the design files task 4 produces; template `blend-plan-view`
  (task 1); blend:project-views "Sync after implementation" (task 3).
- Produces: task nodes `:tNN {:type "task" :state :new :md-ref … :pair […]}`,
  edges `{:direction :-> :type "needs"}`, `tasks/NN-<slug>.md`, and
  overview.md sections `## Plan`, `## Global constraints`,
  `## Review focus`, `## Executing this plan`.

- [ ] **Step 1: Prepare the scenarios**

Scenario A (plan from a design): the design of this very plan at its
design-stage commit — `git -C <repo> archive 9e3b821 | tar -x -C $(mktemp -d)`
(plan graph with no tasks, overview, slices, project views).

Prompt (fresh subagent):

```
You are a coding agent. The design in <REPO>/.blend/2026-10-09-graph-native-plans*
is approved. Load <SKILL> (read it) and the skills it requires
(superpowers:writing-plans at ~/.claude/plugins/cache/claude-plugins-official/superpowers/6.4.1/skills/writing-plans/SKILL.md,
simpleviz:simpleviz). Write the plan. Stop at the hand-off message.
List the files you wrote.
```

Pass: plan graph has ≥ 3 task nodes with `:type "task"`, `:state :new`,
`:md-ref` to existing task files, `:pair` into the plan slices; edges
`:type "needs"`, no cycle; each task file starts `# Task N:` and has
Files, Interfaces and checkbox steps with code; overview.md gained the
four sections; module-slice elements carry `:tasks`; every new/changed/
removed slice element is touched by a task; files clean via `/api/errors`;
no `docs/superpowers/plans/` file; the hand-off names the plan graph.

Scenario B (later session without blend, review focus 5): give a fresh
subagent only the plan from scenario A and this prompt — no blend skill:

```
Execute the first task of the plan at <REPO>/.blend/2026-10-09-graph-native-plans.edn
— just describe what you would read, in what order, and what you would
update when the task is done. Do not edit files.
```

Pass: it finds overview.md's "Executing this plan" via the plan graph's
overview node, reads the task file plus overview and linked views, and
says it sets the node's `:state` to `:in-progress` then `:done`.

- [ ] **Step 2: Run the baseline to verify it fails**

Run scenario A with `<SKILL>` pointing at superpowers:writing-plans
instead. Expected: a `docs/superpowers/plans/*.md` file, no task nodes, no
task files. Record it.

- [ ] **Step 3: Write the skill**

`plugins/blend/skills/planning/SKILL.md`:

````markdown
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

Append to overview.md, paths filled in:

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
````

- [ ] **Step 4: Run the scenarios to verify they pass**

Run A, then B on A's output. Expected: all pass criteria from Step 1. A
failure: tighten the section it skipped, re-run.

- [ ] **Step 5: Commit**

```bash
git add plugins/blend/skills/planning
git commit -m "feat: blend:planning writes task graph, task files and plan notes"
```

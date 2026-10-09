# Graph-native plans — overview

Date: 2026-10-09 · Status: planned · Entry point:
`.blend/2026-10-09-graph-native-plans.edn`

## Goal

Replace blend's markdown spec and plan with simpleviz graphs plus small
markdown files, so the human understands a feature at a glance — what gets
built, in what order, what can run in parallel, which parts of the system
it touches — and agents still get every detail they need to plan and
execute.

The same workflow serves existing projects and greenfield: greenfield is an
existing project whose project views are still empty.

## Background

An eval on two finished features (simpleviz pairs, drapi vidref) compared
plans written from the markdown spec with plans written from the same text
split across a graph with `:md-ref` fragments: requirement coverage was
equal (99.4% vs 99.6%), the graph form cost ~8% more tokens, and judge
scores were within noise. Rearranging the spec text does not improve
planning. The gain this design targets is a different organisation — the
plan's tasks are the entry point, views are shown per task, and the module
graph is kept current — and the human's speed of understanding.

## Decisions

1. **No spec or plan markdown.** `docs/superpowers/specs/` and
   `docs/superpowers/plans/` are no longer written. Their roles move:
   design → `overview.md` + plan views; plan → plan graph + task files.
2. **Two layers of views.**
   - *Project views* in `.blend/views/`: `architecture.edn` (concepts and
     flow, drawn) and `modules.edn` (every module and its import/require
     connections, derived from code). Always current.
   - *Plan views* in `.blend/<date>-<topic>/`: an architecture slice, a
     modules slice, and task-only views when a task needs one no shared
     view shows. A slice holds what the plan touches plus direct
     neighbours as context.
3. **Plan views mark change by `:type`**: `new`, `changed`, `removed`,
   `context`. The element's own type moves to `:kind`; `:change` says what
   changes. Existing elements `:pair` back to their project-view node. No
   simpleviz fork/compare: pairs into a fork are refused, and the plan
   itself has no old version.
4. **The plan graph is the entry point**: `.blend/<date>-<topic>.edn`, at
   `.blend/` level because a ref or pair cannot leave the served file's
   folder. During design it holds the overview node and one node per plan
   view; planning adds the tasks.
5. **Task nodes** carry `:name "N. <title>"`, `:state`, `:md-ref` to their
   task file, `:pair` to the modules and components they touch (in the
   plan slices), and `:ref` to a task-only view if they have one. Edge
   `[:a :b] {:direction :->}`: b needs a done first. Tasks with no path
   between them can run in parallel; the graph shows this, execution stays
   sequential.
6. **`modules.edn` is always maintained**: re-derived from code at the
   start of every brainstorming and after every implementation. Module
   level only (package / namespace / module, whatever the language calls
   it), own modules only; an external library appears only when a plan
   adds it. In large projects, derive the packages a plan touches and grow
   the view over time. The agent derives it; blend ships no per-language
   extractors.
7. **Unplanned changes are reported**: after implementation, the
   re-derived `modules.edn` is compared with the plan's modules slice;
   modules or connections the plan did not predict are listed as review
   items.
8. **Templates.** blend ships `blend-plan`, `blend-architecture`,
   `blend-modules` and `blend-plan-view` in `plugins/blend/templates/`.
   blend's SessionStart hook runs `hooks/install-templates.sh`, which
   copies missing ones to `$SIMPLEVIZ_HOME/templates` (default
   `~/.simpleviz/templates`) and replaces one whose first line
   (`;; blend-template <version>`) differs from blend's. (use-blend reaches
   the agent as hook output, so the agent does not know blend's install
   path; the hook does.)
   Files start from `simpleviz init <file> -t <template>`. Fixed `:type`
   names give stable colours across plans.
9. **Skill split.** blend:brainstorming keeps amending
   superpowers:brainstorming (its process does not depend on the output
   format) and keeps the involvement levels. A new **blend:planning**
   replaces superpowers:writing-plans, whose substance is its format; it
   keeps writing-plans' task rules. A new **blend:project-views** owns
   deriving, drawing and syncing `.blend/views/`; brainstorming and the
   plan's execution notes load it. Execution and finishing stay
   superpowers, pointed at the plan graph.

## Workflow

| Phase | What happens | Gate |
| --- | --- | --- |
| Brainstorming start | Re-derive `.blend/views/modules.edn` (create if missing; empty for greenfield). If `views/architecture.edn` is missing in an existing project, draw the parts the feature touches. | — |
| Present design | Draw the plan's architecture and modules slices (`blend-plan-view`); start the plan graph (`blend-plan`) with the overview and view nodes; serve the plan graph. | design approval, per involvement level |
| Write design | Write `overview.md`; self-review it with the views (superpowers' spec checks plus a clean simpleviz report on every file, see Checking files); commit. | 1 — user reviews overview + views |
| Planning (blend:planning) | Add task nodes and edges to the plan graph; write `tasks/NN-<slug>.md`; set `:tasks` on the modules slice; append "Executing this plan" to `overview.md`; self-review; commit. | 2 — user reviews plan graph + task files, picks execution method |
| Execution | superpowers subagent-driven-development or executing-plans, unchanged; brief per task = task file + `overview.md` + its linked views; `:state` kept current. | superpowers' |
| Finishing | Re-derive `views/modules.edn`, report unplanned modules or connections; apply the architecture slice to `views/architecture.edn`; commit; then superpowers finishing. | report |

Bounded and spike paths write no plan graph, plan views or task files. A
bounded change still re-derives `views/modules.edn` after implementation.

## Task files

`tasks/NN-<slug>.md` is the executor's brief and keeps writing-plans'
rules: goal, exact files (create / modify / test), bite-sized TDD steps
(failing test → run → implement → run → commit) with the code they need,
acceptance criteria, no placeholders, and which views to read.

## Plan notes in the overview

blend:planning appends `## Plan`, `## Global constraints`,
`## Review focus` and `## Executing this plan` to `overview.md`, so a
later session without blend loaded still finds how to run the plan.

## Checking files

Plan views pair into `../views/`, which is inside the folder of the plan
graph but outside their own. `simpleviz check <slice>` therefore warns
"leaves the served folder" although the link works. Check the way the files
are used: serve the plan graph and read `/api/errors?file=<path>` for each
file (all clean in this design), or `simpleviz check` the plan graph and
project views directly.

## Non-goals

- Running tasks in parallel (needs a worktree per task and merging).
- Per-language module extractors shipped with blend.
- Migrating existing `.blend/specs/` files; they stay as history.
- simpleviz fork/compare for plan views.
- A file and folder layout view by default; a plan adds one as a
  task-only view when it needs it.

## Success criteria

- A plan for an existing project and one for a greenfield project both
  produce: project views, plan views, plan graph, `overview.md`, task
  files — and no `docs/superpowers/specs|plans` files.
- Opening the plan graph shows tasks, order and parallelism; following a
  task reaches its task file, its modules and its components.
- After execution, `views/modules.edn` matches the code, and unplanned
  modules or connections were reported.
- Every file blend writes is clean when checked from the plan graph.

## Testing

Skill changes follow superpowers:writing-skills: baseline and green
subagent runs per scenario (greenfield feature, brownfield feature,
plan-to-execution hand-off without blend loaded). Templates get
`simpleviz init -t` + `simpleviz check`. One real dry run in an existing
repo of the user's, reviewed by the user.

## Open points

- `:pair` from a task to the module it builds stretches pair's meaning
  ("the same element in two graphs"); works today. If it reads wrong, a
  dedicated simpleviz attribute can replace it.
- Template refresh on a newer blend overwrites edits to `blend-*`
  templates; customise under another name.
- blend:deduce is out of the workflow; its removal is tracked separately.
- The >150-module scope rule of blend:project-views is untested.
- A `simpleviz check --root <folder>` option would make the per-file
  check one command; until then, use the server route above.

## Plan

Tech stack: Markdown skills (Claude Code + Codex plugin), simpleviz ≥
0.32.0 EDN graphs and templates, POSIX sh for the template installer and
its test. Skill changes are tested the superpowers:writing-skills way:
subagent scenarios run before (baseline) and after (green) the change.

## Global constraints

- Skill names: `blend:brainstorming`, `blend:planning`,
  `blend:project-views`, `use-blend`.
- Paths: plan graph `.blend/YYYY-MM-DD-<topic>.edn`; plan folder
  `.blend/YYYY-MM-DD-<topic>/` with `overview.md`, `architecture.edn`,
  `modules.edn`, `tasks/NN-<slug>.md`; project views
  `.blend/views/architecture.edn`, `.blend/views/modules.edn`.
- Template names: `blend-plan`, `blend-architecture`, `blend-modules`,
  `blend-plan-view`; first line `;; blend-template 0.6.0`.
- Plan-view `:type` values: `new`, `changed`, `removed`, `context`; the
  element's own type in `:kind`; one-line `:change`; `:tasks` on module
  slice elements; task nodes `:type "task"`, edges `:type "needs"`.
- Templates contain no `:pair` (a pair to a missing file warns); show
  pairs in comments.
- simpleviz ≥ 0.32.0 (`init -t`).
- Plugin version 0.6.0 in both manifests.

## Review focus

1. A project with old `.blend/specs/` files: brainstorming must ignore
   them, not treat them as plan views. (Test: task 4, scenario B.)
2. A large repo (hundreds of modules): deriving modules.edn must scope to
   the packages the feature touches, not stall on the whole tree. (Untested: simpleviz has 65 modules, below the threshold — see Open points.)
3. Relative and aliased imports (Python `from . import x`, JS `../x`,
   Clojure `:as`): edges must point at the resolved module. (Test: task 3,
   scenario A.)
4. simpleviz older than 0.32.0 or not installed: the hook must not fail
   the session; templates appear once simpleviz is installed. (Test: task
   1, test cases 1 and 5.)
5. Executing in a later session without blend's skills loaded: the plan
   must explain itself. (Test: task 5, scenario B.)

## Executing this plan

Plan graph: `.blend/2026-10-09-graph-native-plans.edn`. Use
superpowers:subagent-driven-development or superpowers:executing-plans.
For superpowers' helper scripts, PLAN_FILE is the plan graph; skip
`task-brief` and `task-start` — each task file is the task's brief.
Task order follows the graph's edges; tasks without a path between them
are independent. Each task's brief is its task file plus this overview and
the views its node links to. Set the task node's `:state` as you go:
`:in-progress` when started, `:done` once its review is clean, `:blocked`
with `:reason "<why>"`. After the last task, load blend:project-views and
run its "Sync after implementation" against this plan.

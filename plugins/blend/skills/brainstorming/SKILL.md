---
name: brainstorming
description: Use when brainstorming, designing, or writing a spec for any feature or idea — load this instead of loading superpowers:brainstorming directly.
---

# Brainstorming (blend)

Runs superpowers:brainstorming with a visual spec figure alongside it, and
a task graph for the plan that follows. Load superpowers:brainstorming now
and follow it at the involvement level the user picks below. The steps
below amend that process; they do not replace it.

## Involvement level

Your first question, before any other, asks how involved the user wants
to be — multiple choice (use the host's question tool if it has one). It
goes in the same message that announces the path classification.

- **High** — the full superpowers process, every question and gate.
- **Medium** — only questions that change the design, one design review,
  then spec and plan reviews.
- **Full auto** — you decide everything and run through implementation.

Skip the question when the request already names a level ("full auto",
"just decide", "ask me everything"); state the level you took instead.
The level holds until the user changes it.

The chosen level is the user's explicit instruction about the process,
so it overrides the ask-and-wait rules of superpowers and use-blend as
listed here. Under full auto the user has approved every stage in
advance; "a reply approves the stage actually presented" does not apply.

| Step                           | High       | Medium                                                                                                       | Full auto                                         |
| ------------------------------ | ---------- | ------------------------------------------------------------------------------------------------------------ | ------------------------------------------------- |
| Clarifying questions           | as written | only those whose answer changes the design and the repo can't answer; the rest become stated assumptions     | none; decide, record assumptions in spec/design   |
| Write-back, approaches, design | as written | one message: understanding, approaches with recommendation, whole design; one approval                       | no stop                                           |
| Visual companion               | as written | as written                                                                                                   | never offer                                       |
| Spec review                    | stop       | stop                                                                                                         | no stop                                           |
| Plan review + execution method | stop       | stop                                                                                                         | no stop; pick subagent-driven if available        |
| Worktree consent               | as written | as written                                                                                                   | no stop; create the worktree                      |
| Finishing menu                 | stop       | stop                                                                                                         | no stop; keep the branch, never merge or push     |

On a bounded or spike path, the short design or probe approval is the
"design" row; rows for steps the path doesn't have don't apply.

Full auto also:

- Creates the worktree before its first file or commit, so nothing lands
  on the user's checked-out branch.
- Turns every other ask in a downstream skill (failing baseline tests, a
  missing simpleviz, an unclear base branch) into a decision it logs.
- Ends with a report: what was built, every decision made, and the
  figure/spec/plan paths.

Every level still stops for the execution blockers superpowers lists:
destructive or security-sensitive actions, side effects outside the
worktree, a plan too broken to guess past.

## Amendments

**1. Draw the design as you present it.** When you reach "Present design"
in the superpowers checklist, also express the design as a simpleviz graph:
components as nodes, dependencies/data flow as edges, subsystem groupings
as boxes. **REQUIRED SUB-SKILL:** load simpleviz:simpleviz for the EDN
format and how to serve.

- Store the graph at `.blend/specs/YYYY-MM-DD-<topic>.edn` in the target
  project (same date and topic as the spec document).
- Serve it (`simpleviz <file>.edn`) and give the user the URL; the page
  live-reloads, so revise the EDN in place as the design discussion
  changes it.

**2. Amend the figure after the spec is written.** The written spec is the
source of truth. After the spec self-review passes, update the figure to
match the final spec exactly, then commit the `.edn` together with the spec
document.

**3. Draw the plan's tasks.** Once the spec is accepted, continue to
superpowers:writing-plans. When it saves a plan with 3+ tasks, draw the
tasks as a simpleviz graph (load simpleviz:simpleviz if amendment 1 was
skipped):

- File: `.blend/specs/YYYY-MM-DD-<topic>-tasks.edn`, beside the spec
  figure — a `:ref` can't leave the served file's folder.
- One node per task (`:name` "N. <title>", `:state :new`); edge
  `[:a :b] {:direction :->}` when b needs a done first.
- If the spec has a figure: box tasks by the spec component they mainly
  build, each box `:ref "YYYY-MM-DD-<topic>.edn"` to jump to the design.
- Serve it, give the user the URL, commit it with the plan; keep it in
  sync when the plan changes.
- Add a line to the plan header naming the graph file and telling the
  executor to set each task's `:state` alongside its checkbox:
  `:in-progress`, `:done` once its review is clean, `:blocked` + `:reason`.
  Execution often runs in a later session without this skill; the plan
  carries the instruction there.

## Judgment

- The figure covers structure — components, boundaries, flows. Don't force
  requirements, trade-offs, or open questions into the graph; those stay in
  the conversation and the spec.
- A design with fewer than ~3 components doesn't need a figure; say so and
  skip amendment 1.
- This figure is independent of superpowers' visual companion. If the user
  declined the companion, the spec figure is still drawn.

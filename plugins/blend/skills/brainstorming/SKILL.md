---
name: brainstorming
description: Use when brainstorming, designing, or writing a spec for any feature or idea — load this instead of loading superpowers:brainstorming directly.
---

# Brainstorming (blend)

Runs superpowers:brainstorming with a visual spec figure alongside it, and
a task graph for the plan that follows. Load superpowers:brainstorming now
and follow it fully — checklist, hard gate, user review gate all apply. The
steps below amend that process; they do not replace it.

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

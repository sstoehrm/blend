---
name: brainstorming
description: Use when brainstorming, designing, or writing a spec for any feature or idea — load this instead of loading superpowers:brainstorming directly.
---

# Brainstorming (blend)

Runs superpowers:brainstorming with a visual spec figure alongside it.
Load superpowers:brainstorming now and follow it fully — checklist, hard
gate, user review gate all apply. The steps below amend that process; they
do not replace it.

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

**3. Fold the design into the concept graph — optional.** After the user
approves the spec, ask (AskUserQuestion) whether to integrate the new
components into the project's concept graph now, or skip it. If they
integrate, invoke blend:deduce. If they skip, add a TODO line to the spec
document so it isn't lost, and continue to writing-plans.

When it runs, the concept graph is a review gate, not a formality: it is
the first view of the design in context of the whole system. If
integration reveals a misfit — wrong boundary, duplicated concept, an
unwanted dependency — the spec reopens: revise it, re-run the spec
self-review and user review gate, update the spec figure, then
re-integrate.

Continue to superpowers:writing-plans once the spec is accepted and —
unless the user skipped it — the concept graph too.

## Judgment

- The figure covers structure — components, boundaries, flows. Don't force
  requirements, trade-offs, or open questions into the graph; those stay in
  the conversation and the spec.
- A design with fewer than ~3 components doesn't need a figure; say so and
  skip amendment 1 (amendment 3 still applies).
- This figure is independent of superpowers' visual companion. If the user
  declined the companion, the spec figure is still drawn.

---
name: deduce
description: Use when creating or updating a project's concept graph (superficial architecture view) from its code, a plan, or a spec — or when the user asks how the system fits together.
---

# Deduce

Deduce the project's concepts from evidence and maintain them as a simpleviz
graph at `.blend/concept.edn` in the target project. Superficial by intent:
concepts, subsystems, and flows — not classes or files. If a node wouldn't
appear in a whiteboard explanation of the system, it doesn't belong.

**REQUIRED SUB-SKILL:** load simpleviz:simpleviz for the EDN format and
how to serve.

## Process

1. **Load current state.** Read `.blend/concept.edn` if it exists — you are
   updating, not rebuilding. Never silently drop existing nodes. Also read
   `.blend/concept-hash`: the repo commit the graph was last validated
   against.
2. **Gather evidence.** Dispatch Explore subagents over the codebase (entry
   points, module boundaries, build config, data stores, external services).
   If `.blend/concept-hash` exists and git knows the commit, scope the
   sweep: `git diff --name-status <hash>..HEAD` shows what changed since
   the graph was last true — explore those areas, take the rest of the
   graph as still-valid. The scope applies to the sweep only; step 5's
   reviewer still validates every element. No hash, or a hash git can't resolve (rebase,
   squash): full sweep. When invoked from blend:brainstorming, the
   approved spec is the primary evidence and a full code sweep is
   unnecessary.
3. **Propose concepts.** Diff findings against the current graph. Present
   proposed additions/removals/changes to the user (AskUserQuestion,
   multiSelect) with one line of evidence each — the user decides what is a
   concept in their architecture, you decide what the code says. When
   invoked from blend:brainstorming, treat user objections as spec feedback
   first, graph feedback second: a misfit reopens the spec (see
   blend:brainstorming amendment 3), it is not a layout preference.
4. **Update and show.** Apply the accepted changes to `.blend/concept.edn`,
   serve it with simpleviz, give the user the URL. When updating an
   existing graph, serve compare mode instead (old committed version vs
   new, via `git show`) so the user reviews the diff, not the whole graph. Node `:type` examples:
   service, store, ui, external. Edge = real dependency or data flow you can
   point to; box = subsystem/zone grouping.
5. **Validate.** Dispatch a reviewer subagent with the graph and repo access:
   for each node/edge, name the file(s) that evidence it; flag anything
   unsupported, plus obvious concepts the graph missed. Fix findings; take
   new concept candidates back to step 3.
6. **Loop** steps 3–5 until the user confirms the graph and the reviewer has
   no unsupported elements. Then write `git rev-parse HEAD` to
   `.blend/concept-hash` and commit it together with `.blend/concept.edn`
   (the hash is the commit the evidence was gathered from — the graph
   commit's parent).

## Common Mistakes

- File-tree mirroring: one node per directory is a listing, not a deduction.
- Edges from imports alone — an import that carries no meaningful dependency
  or data flow is noise.
- Rebuilding from scratch when a graph exists; history and user decisions
  live in that file.
- Skipping validation because the graph "looks right" — every element needs
  evidence a reviewer could check.

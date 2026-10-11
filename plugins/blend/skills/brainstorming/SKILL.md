---
name: brainstorming
description: Use when the user wants to think through an idea or feature with blend — collecting, discussing and refining it, with what settles written into .blend feature files and the architecture and module graphs.
---

# Brainstorming (blend)

A conversation that leaves a record. The user leads; you collect, ask,
propose and push back. Whatever settles goes into `.blend/`, the
project's spec, right away. No product code, scaffolding or installs.

```
.blend/
  architecture.edn     components, flows, subsystems (simpleviz)
  modules.edn          modules and imports, derived by blend:persist
  features/<slug>.md   one file per feature, free markdown
```

**REQUIRED SUB-SKILL:** simpleviz:simpleviz for the EDN format.

## Start

1. `.blend/views/` exists, or architecture.edn or modules.edn is missing:
   run blend:persist first (it migrates and derives).
2. Read the title and first lines of each feature file, and both graphs.
3. Serve `simpleviz .blend/architecture.edn --no-open` in the background;
   give the user the URL.

## Talking

No fixed order and no gates. Ask a question when its answer would change
something; offer options as a table with your pick; say when an idea
conflicts with the code, the graphs or another feature. Read code
whenever it helps.

## Writing it down

As soon as something settles, not at the end:

- **Feature file** `.blend/features/<slug>.md`: free markdown, whatever
  shape fits. Useful parts: intent, behaviour and examples, open
  questions, and a `Touches:` line naming the graph ids it changes
  (`architecture#<id>`, `modules#<id>`). Edit existing features rather
  than starting duplicates.
- **Graphs**: add or change nodes, edges and boxes the feature implies.
  Elements that don't exist in code yet get `:state :new` and
  `:md-ref "features/<slug>.md"`. Changes to existing elements: edit
  them, and name them in the feature's `Touches:` line.
- Check: `curl -s "$URL/api/errors?file=architecture.edn"` (and
  `modules.edn`) prints no warnings. While the server runs, take
  simpleviz's lock before writing a file the user may have open.

Say in one line what you wrote ("features/due-dates.md: overdue rule").

## Ending

When the user pauses, wraps up or asks: commit only `.blend/` —
`git add .blend && git commit -m "docs: brainstorm <topic>" -- .blend`.
Offer blend:build when they want it built.

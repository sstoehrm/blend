---
name: brainstorming
description: Use when the user wants to think through an idea or feature with blend — collecting, discussing and refining it, with what settles written into .blend/features.md and the architecture and module graphs.
---

# Brainstorming (blend)

A conversation that leaves a record. The user leads; you collect, ask,
propose and push back. Whatever settles goes into `.blend/`, the
project's spec, right away. No product code, scaffolding or installs.

```
.blend/
  intro.md             what the project is; links the rest (serve this)
  features.md          every feature, a ## section each
  architecture.edn     components, flows, subsystems (simpleviz)
  modules.edn          modules and imports, derived by blend:persist
```

**REQUIRED SUB-SKILL:** simpleviz:simpleviz for the EDN format.

## Start

1. `.blend/views/` or `.blend/features/` exists, or one of the four files
   is missing: load blend:persist first, never write them yourself.
2. Read intro.md, the headings and statuses in features.md, both graphs.
3. Serve `simpleviz .blend/intro.md --no-open` in the background; give
   the user the URL — the graphs open beside the text.

## Talking

No fixed order and no gates. Ask a question when its answer would change
something; offer options as a table with your pick; say when an idea
conflicts with the code, the graphs or another feature. Read code
whenever it helps.

## Writing it down

As soon as something settles, not at the end:

- **Feature** — a section in `.blend/features.md`: `## <Name>`,
  `Status: planned`, then free markdown, whatever shape fits. Useful
  parts: intent, behaviour and examples, open questions, and a
  `Touches:` line naming the graph ids it changes (`architecture#<id>`,
  `modules#<id>`). Edit existing sections rather than adding duplicates.
- **Graphs**: add or change nodes, edges and boxes the feature implies.
  Elements that don't exist in code yet get `:state :new` and
  `:md-ref "features.md"`. Changes to existing elements: edit them,
  and name them in the feature's `Touches:` line.
- Check: `curl -s "$URL/api/errors?file=<f>"` for each file you wrote
  prints no warnings. While the server runs, take simpleviz's lock
  before writing a file the user may have open.

Say in one line what you wrote ("features.md, Due dates: overdue rule").

## Ending

When the user pauses, wraps up or asks: commit only `.blend/` —
`git add .blend && git commit -m "docs: brainstorm <topic>" -- .blend`.
Offer blend:build when they want it built.

---
name: persist
description: Use when blend's graphs (.blend/architecture.edn, .blend/modules.edn) should take in work — a range of git history, changes made in this session, the end of a blend build — or when a repo still has the old .blend/views layout.
---

# Persist

Brings the code into blend's two graphs. **REQUIRED SUB-SKILL:**
simpleviz:simpleviz for the EDN format.

| File | Holds | Rule |
| --- | --- | --- |
| `.blend/modules.edn` | own modules and their imports | derived from source, merged (below) |
| `.blend/architecture.edn` | components, flows, subsystems | drawn; updated where code changed |

Source, said before starting: **git** — `<last>..HEAD`, last = `git log
-1 --grep='^docs: persist blend graphs' --format=%H`; or **session** —
`<last>..HEAD` plus this conversation's uncommitted changes. No such
commit: the range is the whole tree. Skip commits that only touch
`.blend/`.

**Old layout** (`.blend/views/`): `git mv .blend/views/*.edn .blend/`,
`git rm .blend/views/system.md`; drop a `;; persisted-through:` line.
Old plan folders stay; their `../views/` pairs will warn.

## Modules: derive and merge

1. Grep the language's module unit and imports (Clojure `ns` +
   `:require`, Python `import`, JS `import`, …). Own modules only.
2. Node id = module name made EDN-safe (`app-io-reader`), `:name` as in
   code, `:type` = top-level package. Edge per import
   `[:a :b] {:direction :-> :type "requires"}`. Box per directory
   `{:name "<dir>" :type "dir" :components #{…}}`, nested as the tree.
   Above ~150 modules: derive what the source touches plus neighbours.
3. Merge into the file, never overwrite: keep ids stable; add derived
   modules and edges that are missing; remove ones gone from code; keep
   `:state :new` nodes and their edges (brainstormed, not built yet) —
   once the module exists in code, drop its `:state` and `:md-ref`.

## Architecture: update

Update in place, never redraw. From `git diff --stat <range>` (whole
tree: the code as it is), update the components whose code changed what
they do or talk to, add new ones, remove deleted ones, keep
`:pair "modules.edn#<id>"` current. `:state :new` elements stay; once
built, they lose `:state` and `:md-ref`. Leave the rest. Missing file:
draw the main components (`:type` service, store, ui, cli, library,
worker, external; edges = flows with `:name`; boxes = subsystems), from
`simpleviz init <file> -t blend-architecture` if you like.

## Check, report, commit

1. `simpleviz check` on both files prints `ok`.
2. Report one line per change; nothing changed: say so, no commit.
3. Commit only `.blend/`, always with this subject — it is the next
   run's start:
   `git add .blend && git commit -m "docs: persist blend graphs" -- .blend`.
   The pathspec keeps the user's staged code out.

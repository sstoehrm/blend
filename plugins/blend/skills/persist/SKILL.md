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

Source, said before starting: **git** — `<marker>..HEAD`, marker = the
`;; persisted-through: <sha>` first line of modules.edn (missing, or not
an ancestor of HEAD: describe the code as it is now); or **session** —
what this conversation changed, committed or not. Skip commits that only
touch `.blend/`.

**Old layout** (`.blend/views/`): `git mv .blend/views/*.edn .blend/`;
system.md's `<!-- persisted-through: <sha> -->` becomes the marker, then
`git rm` it. Old plan folders stay; their `../views/` pairs will warn.

## Modules: derive and merge

1. Module unit and imports per language: Clojure `ns` + `:require`,
   Python module + `import`/`from`, JS/TS file + `import`/`require`, Go
   package + `import`, Rust `mod` + `use crate::`, Lua/Fennel file +
   `require`, C/C++ file + `#include "…"`. Own modules only.
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

From `git diff --stat <range>` (session: plus `git status`): update the
components whose code changed what they do or talk to, add new ones,
remove deleted ones, keep `:pair "modules.edn#<id>"` current; built
`:state :new` elements lose `:state` and `:md-ref`. Leave the rest. Missing file: draw the main
components (`:type` service, store, ui, cli, library, worker, external;
edges = flows with `:name`; boxes = subsystems). Templates:
`simpleviz init <file> -t blend-architecture` / `-t blend-modules`.

## Check, report, commit

1. modules.edn's first line becomes `;; persisted-through: <sha>`, sha =
   `git rev-parse HEAD` before your commit.
2. `simpleviz check` on both files prints `ok`.
3. Report one line per change; nothing changed: say so, no commit.
4. Commit only `.blend/`:
   `git add .blend && git commit -m "docs: persist blend graphs" -- .blend`.
   The pathspec keeps the user's staged code out.

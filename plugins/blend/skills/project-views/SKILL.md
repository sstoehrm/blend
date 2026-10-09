---
name: project-views
description: Use when a project's .blend/views (architecture.edn, modules.edn) must be created, refreshed or synced — at the start of brainstorming, after implementing a plan or a bounded change, or when the user asks how the system or its modules fit together.
---

# Project views

`.blend/views/` holds two simpleviz graphs of the project as it is now:

| File | Shows | Made by |
| --- | --- | --- |
| `architecture.edn` | components, data flow, subsystems | drawn — judgment, checked against the code |
| `modules.edn` | every own module and which modules it imports | derived from source |

**REQUIRED SUB-SKILL:** simpleviz:simpleviz for the EDN format. Start a
missing file from its template:
`simpleviz init .blend/views/modules.edn -t blend-modules`,
`simpleviz init .blend/views/architecture.edn -t blend-architecture`,
then replace the example content.

## Derive modules.edn

1. Find the module unit and import syntax of each language in the repo:
   Clojure `ns` + `:require`, Python module + `import`/`from`, JS/TS file
   + `import`/`require`, Go package + `import`, Rust `mod` + `use crate::`,
   Fennel/Lua file + `require`, C/C++ file + `#include "…"`.
2. Grep the import lines. Resolve relative imports (`from . import x`,
   `../lib/api.js`) and aliases (`:as`, `import … as`) to the module they
   name. Keep own modules only — no standard library, no third-party
   packages.
3. Write one node per module: id = module name made EDN-safe (`app-io-reader`),
   `:name` = the name as written in code (`app.io.reader`), `:type` = its
   top-level package or directory. One edge per "a imports b":
   `[:a :b] {:direction :-> :type "requires"}`. One box per directory or
   package (`:type "dir"`), nested as the tree nests.
4. Scope: up to ~150 modules, derive all. Above that, derive the packages
   the current feature touches plus their direct importers and imports,
   keep what the file already holds, and add `:note "not derived yet: …"`
   to a box whose contents are incomplete.
5. Keep ids stable across derives — pairs from other graphs point at them.
   Overwrite everything else; the file is never edited by hand.
6. `simpleviz check .blend/views/modules.edn` must print `ok`.

## Draw architecture.edn

Only when it is missing, or a feature needs a part it doesn't show. Draw
the components the feature touches, from code and docs: nodes =
components (`:type` service, store, ui, cli, library, worker, external),
edges = data or control flow with `:name`, boxes = subsystems. Link each
component to the modules implementing it: `:pair "modules.edn#<id>"` (a
vector for several). Greenfield: start both files from their templates
and empty them; the first plan fills them.

## Sync after implementation

After the last task of a plan, or after a bounded change:

1. Re-derive `modules.edn`.
2. With a plan: compare it with the plan's modules slice
   (`.blend/<date>-<topic>/modules.edn`). Report to the user, one line
   each: modules or edges that changed in code but are not `new`,
   `changed` or `removed` in the slice, and planned changes that did not
   happen. An empty report says so.
3. With a plan: apply its architecture slice to `architecture.edn` — add
   `new` elements, update `changed` ones, delete `removed` ones, skip
   `context`. Restore `:type` from `:kind`; drop `:change`, `:kind`,
   `:tasks` and pairs into `views/`.
4. `simpleviz check` both files, then commit them together:
   `docs: sync project views`.

## Common mistakes

| Mistake | Fix |
| --- | --- |
| Editing modules.edn by hand | It is overwritten on the next derive; change the code |
| Third-party or stdlib modules as nodes | Own modules only; a plan adds an external as one node |
| New ids on re-derive | Keep ids; pairs into the file break otherwise |
| Deriving all of a huge repo | Scope to the feature's packages (step 4) |

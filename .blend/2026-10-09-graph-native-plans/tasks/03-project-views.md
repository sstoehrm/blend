# Task 3: blend:project-views skill

**Goal:** one skill owns `.blend/views/`: deriving `modules.edn`, drawing
`architecture.edn`, and syncing both after implementation.

**Files:**
- Create: `plugins/blend/skills/project-views/SKILL.md`

**Interfaces:**
- Consumes: templates `blend-modules`, `blend-architecture` (task 1).
- Produces: sections "Derive modules.edn", "Draw architecture.edn" and
  "Sync after implementation", named by tasks 2, 4 and 5 and by the plan's
  "Executing this plan".

- [ ] **Step 1: Prepare the scenarios**

Scenario A (relative and aliased imports, review focus 3): a scratch repo

```sh
D=$(mktemp -d) && mkdir -p $D/app/io $D/web && cd $D && git init -q
printf 'from . import util\nfrom .io import reader as r\n' > app/main.py
printf 'import json\n' > app/util.py
printf 'from ..util import helper\n' > app/io/reader.py
printf 'import x from "../lib/api.js";\n' > web/page.js
mkdir lib && printf 'export default 1;\n' > lib/api.js
touch app/__init__.py app/io/__init__.py
```

Subagent prompt (fresh context):

```
Load the skill at <SKILL> (read the file) and follow it. Do not ask
questions. In the repo <D>, create .blend/views/modules.edn. Report the
nodes and edges you wrote.
```

Pass: nodes app.main, app.util, app.io.reader, web/page, lib/api (ids
EDN-safe); edges main→util, main→io.reader, io.reader→util, page→api;
no `json` node; `simpleviz check` prints `ok`.

Scenario B (scope in a large repo, review focus 2): the simpleviz repo
snapshot `git -C ~/repos/private/simpleviz archive HEAD | tar -x -C $(mktemp -d)`,
prompt: "...derive .blend/views/modules.edn for a feature that changes the
export command (server/export.clj and what it imports)."
Pass: covers server/export and its direct imports/importers, does not
attempt every namespace, notes on a box what is not covered yet, check ok.

Scenario C (sync): after scenario A passes, in the same scratch repo:

```sh
cd $D
printf 'from . import util\nfrom .io import reader as r\nfrom . import export\n' > app/main.py
printf 'from . import util\n' > app/export.py
printf 'import y from "./extra.js";\n' > web/page.js && printf 'export default 2;\n' > web/extra.js
mkdir -p .blend/2026-10-09-csv
cat > .blend/views/architecture.edn <<'EOF'
{:nodes {:app {:name "App" :type "service"} :store {:name "Store" :type "store"}}
 :edges {[:app :store] {:direction :-> :name "reads"}}}
EOF
cat > .blend/2026-10-09-csv/modules.edn <<'EOF'
{:nodes {:app-main {:name "app.main" :type "changed" :kind "app" :change "imports export" :pair "../views/modules.edn#app-main"}
         :app-export {:name "app.export" :type "new" :kind "app" :change "CSV writer"}
         :app-util {:name "app.util" :type "context" :kind "app" :pair "../views/modules.edn#app-util"}}
 :edges {[:app-main :app-export] {:direction :-> :type "new"} [:app-export :app-util] {:direction :-> :type "new"}}}
EOF
cat > .blend/2026-10-09-csv/architecture.edn <<'EOF'
{:nodes {:app {:name "App" :type "changed" :kind "service" :change "exports CSV" :pair "../views/architecture.edn#app"}
         :exporter {:name "CSV exporter" :type "new" :kind "library" :change "writes CSV"}
         :store {:name "Store" :type "removed" :kind "store" :pair "../views/architecture.edn#store"}}
 :edges {[:app :exporter] {:direction :-> :name "export rows" :type "new"}}}
EOF
```

(Adjust the slices' ids to the ids scenario A produced before running.)
Prompt: "...run Sync after implementation for plan 2026-10-09-csv."
Pass: modules.edn re-derived with app.export and web/extra; the report
names web/extra and the page→extra edge as unplanned and nothing else;
architecture.edn has App and CSV exporter, the app→exporter edge, no
Store, and no `:change`/`:kind`/`:tasks` attributes; check ok.

- [ ] **Step 2: Run the baseline to verify it fails**

Run A and B with the prompt's skill path pointing at a non-existent file
(no guidance). Expected: A includes `json` or misses relative edges, or
uses file paths inconsistently; B tries the whole tree or stops without a
file. Record what went wrong.

- [ ] **Step 3: Write the skill**

`plugins/blend/skills/project-views/SKILL.md`:

````markdown
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
````

- [ ] **Step 4: Run the scenarios to verify they pass**

Run A, B and C against the new skill. Expected: all pass criteria from
Step 1 met. A failure: read the transcript, tighten the step it skipped,
re-run that scenario.

- [ ] **Step 5: Commit**

```bash
git add plugins/blend/skills/project-views
git commit -m "feat: blend:project-views derives, draws and syncs .blend/views"
```

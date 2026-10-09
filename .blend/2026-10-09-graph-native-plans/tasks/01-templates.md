# Task 1: simpleviz templates and their installer

**Goal:** blend ships four simpleviz templates and installs them into
simpleviz's templates folder at session start.

**Files:**
- Create: `plugins/blend/templates/blend-plan.edn`
- Create: `plugins/blend/templates/blend-architecture.edn`
- Create: `plugins/blend/templates/blend-modules.edn`
- Create: `plugins/blend/templates/blend-plan-view.edn`
- Create: `plugins/blend/hooks/install-templates.sh`
- Modify: `plugins/blend/hooks/hooks.json`
- Test: `tests/install-templates.test.sh`

**Interfaces:**
- Consumes: nothing.
- Produces: templates `blend-plan`, `blend-architecture`, `blend-modules`,
  `blend-plan-view` usable as `simpleviz init <file> -t <name>`; each file's
  first line is `;; blend-template 0.6.0`. Tasks 3, 4 and 5 name them.

- [ ] **Step 1: Write the failing installer test**

`tests/install-templates.test.sh`:

```sh
#!/usr/bin/env sh
# Tests plugins/blend/hooks/install-templates.sh against temporary homes.
set -u
here="$(cd "$(dirname "$0")" && pwd)"
script="$here/../plugins/blend/hooks/install-templates.sh"
src="$here/../plugins/blend/templates"
fail=0
check() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT

# 1. simpleviz not installed: nothing created, exit 0
SIMPLEVIZ_HOME="$tmp/none" sh "$script"; rc=$?
check "no simpleviz home: exit 0" '[ $rc -eq 0 ]'
check "no simpleviz home: nothing created" '[ ! -e "$tmp/none" ]'

# 2. installed, no templates folder: all four copied
mkdir -p "$tmp/h2"
SIMPLEVIZ_HOME="$tmp/h2" sh "$script"
for t in blend-plan blend-architecture blend-modules blend-plan-view; do
  check "copies $t" 'cmp -s "$src/$t.edn" "$tmp/h2/templates/$t.edn"'
done

# 3. same version, edited by the user: kept
printf '\n;; my edit\n' >> "$tmp/h2/templates/blend-plan.edn"
SIMPLEVIZ_HOME="$tmp/h2" sh "$script"
check "same version edit kept" 'grep -q "my edit" "$tmp/h2/templates/blend-plan.edn"'

# 4. other version: replaced
printf ';; blend-template 0.0.1\n{}\n' > "$tmp/h2/templates/blend-modules.edn"
SIMPLEVIZ_HOME="$tmp/h2" sh "$script"
check "other version replaced" 'cmp -s "$src/blend-modules.edn" "$tmp/h2/templates/blend-modules.edn"'

# 5. templates is a file: no crash, exit 0, file untouched
mkdir -p "$tmp/h5"; echo keep > "$tmp/h5/templates"
SIMPLEVIZ_HOME="$tmp/h5" sh "$script"; rc=$?
check "templates file: exit 0" '[ $rc -eq 0 ]'
check "templates file: untouched" '[ "$(cat "$tmp/h5/templates")" = keep ]'

# 6. user templates survive
mkdir -p "$tmp/h6/templates"; echo '{}' > "$tmp/h6/templates/web.edn"
SIMPLEVIZ_HOME="$tmp/h6" sh "$script"
check "user template kept" '[ "$(cat "$tmp/h6/templates/web.edn")" = "{}" ]'

# 7. every template parses and checks clean
for t in "$src"/blend-*.edn; do
  check "simpleviz check $(basename "$t")" 'simpleviz check "$t" >/dev/null'
done

# 8. every template starts with the version line
for t in "$src"/blend-*.edn; do
  check "version line $(basename "$t")" '[ "$(head -n 1 "$t")" = ";; blend-template 0.6.0" ]'
done
exit $fail
```

- [ ] **Step 2: Run it to verify it fails**

Run: `sh tests/install-templates.test.sh`
Expected: FAIL lines (script and templates missing), exit 1.

- [ ] **Step 3: Write the installer**

`plugins/blend/hooks/install-templates.sh`:

```sh
#!/usr/bin/env sh
# Copy blend's simpleviz templates into simpleviz's templates folder.
# Adds missing ones; replaces one whose first line (;; blend-template
# <version>) differs from blend's. Does nothing without a simpleviz install.
# Prints nothing: SessionStart hook output becomes session context.
src="$(cd "$(dirname "$0")/../templates" 2>/dev/null && pwd)" || exit 0
home="${SIMPLEVIZ_HOME:-$HOME/.simpleviz}"
[ -d "$home" ] || exit 0
[ -e "$home/templates" ] && [ ! -d "$home/templates" ] && exit 0
mkdir -p "$home/templates" 2>/dev/null || exit 0
for f in "$src"/blend-*.edn; do
  [ -f "$f" ] || continue
  dst="$home/templates/$(basename "$f")"
  if [ ! -f "$dst" ] || [ "$(head -n 1 "$f")" != "$(head -n 1 "$dst")" ]; then
    cp "$f" "$dst" 2>/dev/null
  fi
done
exit 0
```

- [ ] **Step 4: Write the four templates**

`plugins/blend/templates/blend-plan.edn`:

```clojure
;; blend-template 0.6.0
;; Plan graph: the entry point of a blend plan. Serve this file.
;; Replace DATE-TOPIC with the plan folder name (YYYY-MM-DD-<topic>).
;; Design stage: keep the overview and view nodes, delete the example tasks.
;; blend:planning adds one node per task:
;;   :tNN {:name "N. <title>" :type "task" :state :new
;;         :md-ref "DATE-TOPIC/tasks/NN-<slug>.md"
;;         :pair ["DATE-TOPIC/modules.edn#<id>" "DATE-TOPIC/architecture.edn#<id>"]
;;         :ref "DATE-TOPIC/<task-only-view>.edn"}   ; only when the task needs one
;; :state is :new, :in-progress, :done or :blocked (+ :reason "<why>").
;; Edge [:tA :tB] {:direction :-> :type "needs"}: B needs A done first.
;; Box tasks by the architecture component they mainly build (:type "component").
{:nodes {:overview     {:name "Overview" :type "doc" :md-ref "DATE-TOPIC/overview.md"}
         :architecture {:name "Architecture (plan)" :type "view" :ref "DATE-TOPIC/architecture.edn"}
         :modules      {:name "Modules (plan)" :type "view" :ref "DATE-TOPIC/modules.edn"}
         :proj-arch    {:name "Architecture (project)" :type "view" :ref "views/architecture.edn"}
         :proj-modules {:name "Modules (project)" :type "view" :ref "views/modules.edn"}
         :t01          {:name "1. Example task" :type "task" :state :new
                        :md-ref "DATE-TOPIC/tasks/01-example-task.md"}
         :t02          {:name "2. Example task" :type "task" :state :new
                        :md-ref "DATE-TOPIC/tasks/02-example-task.md"}}
 :edges {[:architecture :proj-arch] {:direction :-> :name "changes"}
         [:modules :proj-modules]   {:direction :-> :name "changes"}
         [:t01 :t02]                {:direction :-> :type "needs"}}
 :boxes {:design  {:name "Design" :type "design" :components #{:overview :architecture :modules}}
         :project {:name "Project views" :type "project" :components #{:proj-arch :proj-modules}}}}
```

`plugins/blend/templates/blend-architecture.edn`:

```clojure
;; blend-template 0.6.0
;; Project view: the system's architecture as it is now (.blend/views/architecture.edn).
;; Nodes = components, :type one of service, store, ui, cli, library, worker, external.
;; Edges = data or control flow, :name says what flows.
;; Boxes = subsystems (:type "subsystem").
;; Link a component to the modules implementing it:
;;   :pair "modules.edn#<module-id>"   (a vector for several)
{:nodes {:ui    {:name "UI" :type "ui"}
         :api   {:name "API" :type "service"}
         :store {:name "Store" :type "store"}}
 :edges {[:ui :api]    {:direction :-> :name "requests"}
         [:api :store] {:direction :-> :name "reads / writes"}}
 :boxes {:backend {:name "Backend" :type "subsystem" :components #{:api :store}}}}
```

`plugins/blend/templates/blend-modules.edn`:

```clojure
;; blend-template 0.6.0
;; Project view: every own module and which modules it imports
;; (.blend/views/modules.edn). Derived from source by blend:project-views;
;; do not edit by hand, it is overwritten on the next derive.
;; Node id = module name made EDN-safe; :name = the name as written in code;
;; :type = top-level package or directory. External libraries only when a
;; plan adds one (:type "external").
;; Edge [:a :b] {:direction :-> :type "requires"}: a imports b.
;; Boxes = directories / packages (:type "dir"), nested as the tree nests.
{:nodes {:app-core {:name "app.core" :type "app"}
         :app-db   {:name "app.db" :type "app"}}
 :edges {[:app-core :app-db] {:direction :-> :type "requires"}}
 :boxes {:app {:name "src/app" :type "dir" :components #{:app-core :app-db}}}}
```

`plugins/blend/templates/blend-plan-view.edn`:

```clojure
;; blend-template 0.6.0
;; Plan view: the slice of a project view a plan touches, or a task-only view
;; (.blend/DATE-TOPIC/architecture.edn, modules.edn, <view>.edn).
;; :type is the change, so it gets the color:
;;   "new" | "changed" | "removed" | "context" (direct neighbour, unchanged)
;; :kind  = the element's own type in the project view
;; :change = one line: what changes
;; :tasks = ["N. <title>" ...] in the modules slice: the tasks touching it
;; Existing elements link back to their project-view node:
;;   :pair "../views/modules.edn#<id>"   (or ../views/architecture.edn#<id>)
;; Edges carry :type too: new, changed, removed or context.
{:nodes {:core {:name "app.core" :type "changed" :kind "app"
                :change "calls the new exporter" :tasks ["2. Wire exporter"]}
         :exporter {:name "app.export" :type "new" :kind "app"
                    :change "writes CSV" :tasks ["1. Exporter"]}
         :db {:name "app.db" :type "context" :kind "app"}}
 :edges {[:core :exporter] {:direction :-> :type "new"}
         [:core :db]       {:direction :-> :type "context"}}
 :boxes {:app {:name "src/app" :type "context" :components #{:core :exporter :db}}}}
```

- [ ] **Step 5: Register the installer in the SessionStart hook**

`plugins/blend/hooks/hooks.json` — add a second command after the `cat`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "cat \"${CLAUDE_PLUGIN_ROOT}/skills/use-blend/SKILL.md\""
          },
          {
            "type": "command",
            "command": "sh \"${CLAUDE_PLUGIN_ROOT}/hooks/install-templates.sh\""
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 6: Run the test to verify it passes**

Run: `sh tests/install-templates.test.sh`
Expected: every line `ok`, exit 0.

Then against the real install:
Run: `sh plugins/blend/hooks/install-templates.sh && D=$(mktemp -d) && simpleviz init $D/p.edn -t blend-plan && simpleviz check $D/p.edn`
Expected: `ok`.

- [ ] **Step 7: Commit**

```bash
git add plugins/blend/templates plugins/blend/hooks tests/install-templates.test.sh
git commit -m "feat: blend simpleviz templates, installed at session start"
```

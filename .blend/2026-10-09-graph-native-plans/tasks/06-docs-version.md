# Task 6: README and version 0.6.0

**Goal:** the README describes the graph-native workflow; both manifests
carry 0.6.0.

**Files:**
- Modify: `README.md` (Skills table, The workflow section, artifacts tree)
- Modify: `plugins/blend/.claude-plugin/plugin.json` (version)
- Modify: `plugins/blend/.codex-plugin/plugin.json` (version, descriptions)

**Interfaces:**
- Consumes: skill names and paths from tasks 1–5.
- Produces: nothing other tasks use.

- [ ] **Step 1: Write the check**

```sh
cd <repo>
fail=0
for f in plugins/blend/.claude-plugin/plugin.json plugins/blend/.codex-plugin/plugin.json; do
  python3 -c "import json,sys; v=json.load(open('$f'))['version']; sys.exit(v!='0.6.0')" || { echo "FAIL version $f"; fail=1; }
done
for s in blend:planning blend:project-views blend-plan-view "views/modules.edn"; do
  grep -q "$s" README.md || { echo "FAIL README lacks $s"; fail=1; }
done
grep -q "docs/superpowers/specs\|\.blend/specs/" README.md && { echo "FAIL README still names old artifacts"; fail=1; }
echo "exit $fail"
```

- [ ] **Step 2: Run it to verify it fails**

Expected: version FAILs (0.5.0), README FAILs, old artifacts FAIL.

- [ ] **Step 3: Bump both manifests**

`"version": "0.5.0"` → `"version": "0.6.0"` in both plugin.json files. In
the Codex manifest set
`"shortDescription": "Visual design and graph-native plans"` and
`"longDescription": "Combine superpowers workflows with simpleviz plan graphs, task files and always-current architecture and module views."`.

- [ ] **Step 4: Rewrite the README's Skills table rows for blend**

```markdown
| use-blend           | Injected into every session via SessionStart hook. Communication style, verification habits, dependency checks, and the phase → skill routing table. The hook also installs blend's simpleviz templates. |
| blend:brainstorming | Wraps superpowers:brainstorming: asks how involved you want to be (high, medium, full auto), refreshes the project views, draws the design as plan views with a plan graph as entry point, and writes `overview.md` instead of a spec. |
| blend:planning      | Replaces superpowers:writing-plans: adds the tasks to the plan graph (dependencies show what can run in parallel), writes one task file per task, and tells execution how to run the plan. |
| blend:project-views | Keeps `.blend/views/architecture.edn` and `.blend/views/modules.edn` current: derives the module graph from code, draws architecture, syncs both after implementation and reports unplanned changes. |
```

Keep the blend:deduce row as it is on this branch.

- [ ] **Step 5: Rewrite "The workflow" section up to "Brainstorming first asks how involved"**

````markdown
## The workflow

```
idea ──▶ blend:brainstorming ──▶ overview.md + plan views ──▶ blend:planning ──▶ plan graph + task files ──▶ implementation ──▶ sync project views
              │                         ▲                                                                                        │
              ▼                         └──── .blend/views (architecture, modules) ◀─────────────────────────────────────────────┘
      superpowers:brainstorming
```

There is no spec or plan document. Brainstorming refreshes the project
views, then draws what the feature changes as plan views — a slice of the
architecture and of the module graph, marked new / changed / removed /
context — and writes a short `overview.md` (goal, decisions, non-goals,
success criteria). You review those. blend:planning adds the tasks to the
plan graph: edges show order, tasks without a path between them can run
in parallel, and each task links to its task file and to the modules and
components it touches. After implementation the module graph is
re-derived from the code and anything the plan did not predict is
reported.
````

- [ ] **Step 6: Replace the artifacts tree**

````markdown
Artifacts land in the target project:

```
.blend/
├── views/architecture.edn             # project: components and flows, always current
├── views/modules.edn                  # project: every module and its imports, derived from code
├── YYYY-MM-DD-<topic>.edn             # plan graph — the entry point; serve this
└── YYYY-MM-DD-<topic>/
    ├── overview.md                    # goal, decisions, non-goals, success criteria, how to execute
    ├── architecture.edn               # what the plan changes in the architecture
    ├── modules.edn                    # which modules the plan touches, and by which task
    └── tasks/NN-<slug>.md             # one brief per task: files, TDD steps, acceptance
```

Templates: `simpleviz init <file> -t blend-plan | blend-plan-view | blend-architecture | blend-modules`.
````

- [ ] **Step 7: Run the check to verify it passes**

Run the Step 1 script. Expected: `exit 0`, no FAIL lines.

- [ ] **Step 8: Commit**

```bash
git add README.md plugins/blend/.claude-plugin/plugin.json plugins/blend/.codex-plugin/plugin.json
git commit -m "docs: graph-native workflow in README; version 0.6.0"
```

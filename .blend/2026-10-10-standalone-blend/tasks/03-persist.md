# Task 3: blend:persist (replaces project-views)

**Goal:** one skill keeps the global spec — `.blend/views/modules.edn`,
`architecture.edn` and the new `system.md` — current from a git range,
the current session, or a finished plan.

**Files:**
- Create: `plugins/blend/skills/persist/SKILL.md`
- Delete: `plugins/blend/skills/project-views/SKILL.md`
- Modify: `plugins/blend/templates/blend-*.edn` (line 1 → `;; blend-template 0.7.0`;
  blend-modules.edn line 4: `blend:project-views` → `blend:persist`)
- Modify: `tests/install-templates.test.sh:53` (`0.6.0` → `0.7.0`)

**Interfaces:**
- Consumes: `tests/scenarios/run.sh`, `setup.sh` (task 1).
- Produces: `blend:persist` with sources `git`, `session`, `plan`
  (named exactly so by tasks 5 and 7); `system.md` format with the marker
  line `<!-- persisted-through: <sha> -->`; commit message
  `docs: persist project views`.

- [ ] **Step 1: Write the scenario prompts**

Each prompt starts: `Load the skill blend:persist and follow it. Do not
ask questions; decide and say what you decided.`

| # | Fixture | Rest of the prompt | Pass |
| --- | --- | --- | --- |
| S8 | `blackboard` | `Persist the git history into the global spec.` | modules.edn lists the `src/` namespaces with require edges, no third-party nodes; architecture.edn exists with components pairing into modules.edn; system.md has the marker = `git rev-parse HEAD~1` of the result (HEAD is the persist commit), Purpose, ≥ 1 Decision with a source; one commit `docs: persist project views` touching only `.blend/views/`; `simpleviz check` ok on both EDN files |
| S8b | `blackboard`, after S8's commit, then `git commit --allow-empty -m "Use EDN files instead of a database — simpler to diff"` | `Persist the git history into the global spec.` | range starts at S8's marker (says so); the new decision appears in system.md; modules.edn unchanged |
| S9 | `cli-small`, then the agent-unrelated edit below, uncommitted | `I just added the done command in this session (see the working tree). We decided done items stay in the list rather than being deleted. Persist the session.` | views created; system.md Decisions contains the stay-in-list decision; `git status` still shows `todo.py` modified and uncommitted; the persist commit touches only `.blend/views/` |
| S10 | `sync-plan` | `The plan .blend/2026-10-09-csv.edn is finished. Persist the plan.` | the report names `web/extra.js` (node and page→extra edge) as unplanned and the removed page→api edge; architecture.edn has App and CSV exporter, the app→exporter edge, no Store, no `:change`/`:kind`/`:tasks`; check ok |

S9's edit before running (leave it uncommitted):

```sh
python3 - <<'EOF'
p = "todo.py"; s = open(p).read()
s = s.replace('''    elif argv[:1] == ["list"]:''', '''    elif argv[:1] == ["done"]:
        todos[int(argv[1]) - 1]["done"] = True
        DB.write_text(json.dumps(todos))
    elif argv[:1] == ["list"]:''')
open(p, "w").write(s)
EOF
```

- [ ] **Step 2: Run the baselines**

Arm `old` with `blend:persist` replaced by `blend:project-views` in the
prompts. Expected: S8 and S9 write no system.md and no marker; S9 has no
"session" mode. Record the summary lines.

- [ ] **Step 3: Write the skill**

`plugins/blend/skills/persist/SKILL.md`:

````markdown
---
name: persist
description: Use when the global spec in .blend/views (modules.edn, architecture.edn, system.md) should take in recent work — after ad-hoc changes in a session, for a range of git history, after a blend plan is finished, at the start of a blend brainstorm, or when the user asks how the system or its modules fit together.
---

# Persist

`.blend/views/` is the project's global spec:

| File | Holds | Made by |
| --- | --- | --- |
| `modules.edn` | every own module and what it imports | derived from source; never edited by hand |
| `architecture.edn` | components, data flow, subsystems | drawn, checked against the code |
| `system.md` | purpose, constraints, decisions | written from commits, sessions and plans |

Persist brings one source of change into all three.
**REQUIRED SUB-SKILL:** simpleviz:simpleviz for the EDN format.

## Source

| Source | Use when | Range |
| --- | --- | --- |
| git | the user asks for history; blend:brainstorming starts | `<from>..HEAD`: `<from>` = system.md's marker, else the user's range; neither → describe the code as it is now |
| session | after ad-hoc work in this conversation | what this conversation changed, committed or not, and what was decided in it |
| plan | after the last task of `.blend/<plan>.edn` | the plan's slices and its overview.md |

Say the source and range before starting. Skip commits that only touch
`.blend/views/`.

## 1. Derive modules.edn

1. Find each language's module unit and import syntax: Clojure `ns` +
   `:require`, Python module + `import`/`from`, JS/TS file +
   `import`/`require`, Go package + `import`, Rust `mod` + `use crate::`,
   Fennel/Lua file + `require`, C/C++ file + `#include "…"`.
2. Grep the import lines in the working tree. Resolve relative imports
   and aliases to the module they name. Own modules only — no standard
   library, no third-party packages.
3. One node per module: id = module name made EDN-safe (`app-io-reader`),
   `:name` = the name as in code, `:type` = top-level package or
   directory. One edge per import: `[:a :b] {:direction :-> :type "requires"}`.
   One box per directory or package (`:type "dir"`), nested as the tree.
4. Up to ~150 modules: derive all. Above: the packages the source touches
   plus their direct importers and imports; keep what the file holds;
   `:note "not derived yet: …"` on boxes left incomplete.
5. Keep ids stable — other graphs `:pair` into them. Overwrite the rest.

## 2. Update architecture.edn

- **plan:** apply the plan's architecture slice. Match each slice element
  to the element its `:pair` names (`new` ones: add under their slice id);
  update `changed`, delete `removed`, skip `context`. Restore `:type` from
  `:kind`; drop `:change`, `:kind`, `:tasks` and pairs into `views/`.
- **git / session:** from `git diff --stat <range>` (session: plus
  `git status`), update only the components whose code changed what they
  do or talk to: nodes, edges, `:pair "modules.edn#<id>"`. Add new
  components, remove deleted ones. Leave the rest.
- Missing file: draw the components the source touches (none: the main
  ones). Nodes = components (`:type` service, store, ui, cli, library,
  worker, external), edges = data or control flow with `:name`, boxes =
  subsystems.

## 3. Update system.md

```markdown
<!-- persisted-through: <sha> -->
# System

## Purpose
<two or three sentences>

## Constraints
- <constraint>

## Decisions
- YYYY-MM-DD — <decision> — <why> — <source: commit sha, "session" or the plan name>
```

- A decision is something future work must respect: a chosen library or
  format, a boundary, a rejected approach with its reason. What changed
  is not a decision; that stays in git.
- git: commit messages and changed docs in the range; above ~50 commits,
  read `git log --oneline` and the diff stat, open only commits that name
  a decision. session: what the user and you decided. plan: the
  overview's `## Decisions` that still hold.
- A decision that replaces an older one replaces its line. Purpose and
  Constraints change only when the source says so.
- Marker = `git rev-parse HEAD` before your commit.

## 4. Report

One line per change to the three files. Plan source also: modules or
edges that changed in code but are not `new`, `changed` or `removed` in
the plan's modules slice, and planned changes that didn't happen. Nothing
changed: say so.

## 5. Check and commit

`simpleviz check` on both EDN files prints `ok`. Then commit only the
views: `git add .blend/views && git commit -m "docs: persist project views"`.
Never stage the user's other changes. Nothing changed: no commit.

Starting files from templates is optional:
`simpleviz init .blend/views/modules.edn -t blend-modules` (or
`-t blend-architecture`), then replace the example content.

## Common mistakes

| Mistake | Fix |
| --- | --- |
| Editing modules.edn by hand | Re-derive; change the code instead |
| Stdlib or third-party modules as nodes | Own modules only |
| New ids on re-derive | Keep ids; pairs break otherwise |
| A changelog in Decisions | Only what future work must respect |
| Committing the user's code with the views | `git add .blend/views` only |
````

- [ ] **Step 4: Remove project-views, bump templates**

```sh
git rm -q plugins/blend/skills/project-views/SKILL.md
sed -i '1s/0\.6\.0/0.7.0/' plugins/blend/templates/blend-*.edn
sed -i '4s/blend:project-views/blend:persist/' plugins/blend/templates/blend-modules.edn
sed -i '53s/0\.6\.0/0.7.0/' tests/install-templates.test.sh
sh tests/install-templates.test.sh
```

Expected: every check `ok`.

- [ ] **Step 5: Run the scenarios**

S8, S8b, S9, S10 with arm `new`. Expected: the pass column of Step 1,
`superpowers_uses=0`. `wc -l` on the skill ≤ 120.

- [ ] **Step 6: Commit**

```sh
git add plugins/blend/skills/persist plugins/blend/templates tests/install-templates.test.sh
git commit -m "feat: blend:persist keeps views and system.md current; replaces project-views"
```

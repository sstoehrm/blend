---
name: persist
description: Use when the global spec in .blend/views (modules.edn, architecture.edn, system.md) should take in recent work — after ad-hoc changes in a session, for a range of git history, after a blend plan is finished, or at the start of a blend brainstorm.
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
   One box per directory or package
   `{:name "<dir>" :type "dir" :components #{…}}`, nested as the tree.
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
- session / plan: also read commit messages in `<marker>..HEAD`, as git
  does. A marker that is not an ancestor of HEAD (rebase, squash) counts
  as no marker.
- Marker = `git rev-parse HEAD` before your commit.

## 4. Report

One line per change to the three files. Plan source also, by name: each
module node and each edge that changed in code but is not `new`,
`changed` or `removed` in the plan's modules slice ("unplanned"), and
planned changes that didn't happen. Nothing
changed: say so.

## 5. Check and commit

`simpleviz check` on both EDN files prints `ok`. Then commit only the
views: `git add .blend/views && git commit -m "docs: persist project views" -- .blend/views`.
The pathspec keeps the user's staged code out. Nothing changed: no commit.

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
| Committing the user's code with the views | `git add .blend/views`, commit with `-- .blend/views` |

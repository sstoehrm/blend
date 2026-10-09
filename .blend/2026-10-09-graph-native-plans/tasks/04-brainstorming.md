# Task 4: blend:brainstorming writes plan views and overview.md

**Goal:** brainstorming refreshes the project views, draws the design as
plan views plus a plan graph, writes `overview.md` instead of a spec, and
hands off to blend:planning. The involvement levels stay.

**Files:**
- Modify: `plugins/blend/skills/brainstorming/SKILL.md` (full rewrite below)

**Interfaces:**
- Consumes: templates `blend-plan`, `blend-plan-view` (task 1);
  blend:project-views "Derive modules.edn" and "Draw architecture.edn"
  (task 3).
- Produces: `.blend/<date>-<topic>.edn` (overview + view nodes),
  `.blend/<date>-<topic>/overview.md`, `architecture.edn`, `modules.edn` —
  task 5's input.

- [ ] **Step 1: Prepare the scenarios**

Scenario A (greenfield): an empty git repo `G=$(mktemp -d) && git -C $G init -q`.
Scenario B (brownfield with old artifacts, review focus 1): a snapshot of
the drapi repo — `git -C ~/repos/private/drapi archive HEAD | tar -x -C $(mktemp -d)` —
which contains `.blend/specs/*.edn` and `docs/superpowers/specs/*.md`.

Prompt (fresh subagent; `<SKILL>` = brainstorming SKILL.md under test):

```
You are a coding agent. Load <SKILL> (read it) and the skills it requires
(superpowers:brainstorming at ~/.claude/plugins/cache/claude-plugins-official/superpowers/6.4.1/skills/brainstorming/SKILL.md,
blend:project-views at <PROJECT_VIEWS>, simpleviz:simpleviz). Repo: <REPO>.
User: "Full auto. Add <FEATURE>."
Run brainstorming up to and including the written design and its
self-review. Stop before planning. List every file you created or changed
and the gates you passed.
```

A: FEATURE = "a CLI that converts CSV to JSON, Python".
B: FEATURE = "an undo history panel that lists the last 20 edits".

Pass (both): files exist — `.blend/views/modules.edn`,
`.blend/views/architecture.edn`, `.blend/<date>-<topic>.edn`,
`.blend/<date>-<topic>/overview.md`, `.../architecture.edn`,
`.../modules.edn`; no new file under `docs/superpowers/` or `.blend/specs/`;
plan views use `:type` new/changed/removed/context; the plan graph has the
overview and view nodes and no task nodes; every file is clean via the
server's `/api/errors` from the plan graph; the next step named is
blend:planning. B also: the old `.blend/specs/` files are neither edited
nor used as views; modules.edn reflects drapi's Fennel modules.

- [ ] **Step 2: Run the baseline to verify it fails**

Run A and B with `<SKILL>` = the current file. Expected: writes
`docs/superpowers/specs/...-design.md` and `.blend/specs/<date>-<topic>.edn`;
no project or plan views. Record the file lists.

- [ ] **Step 3: Rewrite the skill**

`plugins/blend/skills/brainstorming/SKILL.md` — keep lines 1–57 (front
matter, title, Involvement level section) with these changes, then
replace everything from `## Amendments` to the end.

Front matter description stays. Replace the intro paragraph (lines 8–11):

```markdown
Runs superpowers:brainstorming, with the design kept as simpleviz graphs
and a short `overview.md` instead of a spec document; planning continues
in blend:planning. Load superpowers:brainstorming now and follow it at the
involvement level the user picks below. The steps below amend that
process; they do not replace it.
```

In the involvement table, rename two step labels and one cell:

```markdown
| Design review (overview + views) | stop       | stop | no stop |
| Plan review + execution method   | stop       | stop | no stop; pick subagent-driven if available |
```

(i.e. "Spec review" → "Design review (overview + views)"; the full auto
clarifying-questions cell "record assumptions in spec/design" → "record
assumptions in overview.md"), and in "Full auto also" change "the
figure/spec/plan paths" to "the plan graph path".

Replace from `## Amendments` to the end with:

````markdown
## Amendments

**1. Refresh the project views first.** Right after announcing the path,
before clarifying questions: **REQUIRED SUB-SKILL:** blend:project-views.
Re-derive `.blend/views/modules.edn` (create it if missing). If
`.blend/views/architecture.edn` is missing in a project with code, draw
the parts this feature touches. Greenfield: create both from their
templates, emptied. Ignore `.blend/specs/` — files from blend's earlier
format, history only.

**2. Draw the design as plan views.** At "Present design" (architectural
path), with `<plan>` = `YYYY-MM-DD-<topic>`. **REQUIRED SUB-SKILL:**
simpleviz:simpleviz.

- `.blend/<plan>/architecture.edn` and `.blend/<plan>/modules.edn`, each
  from `simpleviz init <file> -t blend-plan-view`: what the design
  touches plus direct neighbours. `:type` is `new`, `changed`, `removed`
  or `context`; the element's own type goes in `:kind`; `:change` says
  what changes in one line; existing elements `:pair` to
  `"../views/<file>#<id>"`.
- `.blend/<plan>.edn` from `simpleviz init <file> -t blend-plan`: replace
  `DATE-TOPIC`, delete the example tasks. It is the entry point.
- Serve it in the background (`simpleviz .blend/<plan>.edn --no-open`)
  and give the user the URL. Revise the views in place as the discussion
  changes the design.

**3. Write overview.md instead of the spec.** Where superpowers writes the
design doc to `docs/superpowers/specs/`, write `.blend/<plan>/overview.md`
instead: Goal, Decisions, Behavior or Workflow as the design needs,
Non-goals, Success criteria, Testing, Open points. Self-review it as
superpowers says, plus: every file is clean when checked from the plan
graph — with the plan graph served, `curl -s "$URL/api/errors?file=<path>"`
for each file prints no warnings. (`simpleviz check` on a plan view alone
warns that `../views` leaves the folder; the link is fine.) Commit the plan
graph, the plan folder and `.blend/views/` together. The user review gate
covers overview.md and the views: give the plan graph URL and the
overview path.

**4. Plan with blend:planning.** Where superpowers invokes writing-plans,
invoke blend:planning instead. Never superpowers:writing-plans; nothing
under `docs/superpowers/specs/` or `docs/superpowers/plans/`.

Bounded and spike paths write no plan graph, plan views or overview. A
bounded change runs blend:project-views' "Sync after implementation"
after it is implemented.

## Judgment

- Views show structure — components, modules, flows. Requirements,
  trade-offs and open questions go in overview.md.
- The modules slice is always drawn: it is how the user sees a plan's
  reach. An architecture slice with fewer than ~3 touched components may
  be skipped; say so in overview.md.
- The plan views are independent of superpowers' visual companion; they
  are drawn whether or not the user accepted it.
````

- [ ] **Step 4: Run the scenarios to verify they pass**

Run A and B against the rewritten skill. Expected: all pass criteria
from Step 1 met. A failure: tighten the amendment it skipped, re-run.

- [ ] **Step 5: Commit**

```bash
git add plugins/blend/skills/brainstorming/SKILL.md
git commit -m "feat(brainstorming): design as plan views and overview.md, hand off to blend:planning"
```

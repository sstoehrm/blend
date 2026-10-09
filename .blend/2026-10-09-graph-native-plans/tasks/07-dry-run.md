# Task 7: End-to-end dry run, greenfield and brownfield

**Goal:** prove the success criteria with the finished skills, as a fresh
session would meet them, and fix what the run exposes.

**Files:**
- Modify: whichever skill or template the run shows wrong (tasks 1–5's
  files), nothing else.
- Test: two scratch repos, not committed.

**Interfaces:**
- Consumes: everything from tasks 1–6.
- Produces: the evidence for overview.md's success criteria.

- [ ] **Step 1: Install the branch's plugin state**

Run: `sh plugins/blend/hooks/install-templates.sh && ls ~/.simpleviz/templates/`
Expected: `blend-architecture.edn blend-modules.edn blend-plan.edn blend-plan-view.edn default.edn`.

- [ ] **Step 2: Greenfield run**

`G=$(mktemp -d) && git -C $G init -q`. One fresh subagent, prompt:

```
You are a coding agent in a fresh session. Read and follow, in this order:
<repo>/plugins/blend/skills/use-blend/SKILL.md (injected at session start),
then whatever it routes to; blend skills are in <repo>/plugins/blend/skills/,
superpowers skills in ~/.claude/plugins/cache/claude-plugins-official/superpowers/6.4.1/skills/.
Repo: <G>. User: "Full auto. Build a Python CLI that converts CSV to JSON,
with a --pretty flag." Go through design and planning, then STOP before
executing any task. List every file written.
```

Expected: `.blend/views/{architecture,modules}.edn`, plan graph with ≥ 3
tasks, plan folder with overview.md (including "Executing this plan"), both slices, task files; nothing under `docs/superpowers/`;
every file clean via the server's `/api/errors` from the plan graph.

- [ ] **Step 3: Brownfield run**

Same prompt with Repo = a snapshot of `~/repos/private/odin-edn`
(`git -C ~/repos/private/odin-edn archive HEAD | tar -x -C $(mktemp -d)`)
and User: "Full auto. Add a pretty-printer that writes EDN with
indentation." Expected as in Step 2, plus: modules.edn holds odin-edn's
own packages; the modules slice marks the new printer `new` and the
packages it uses `context` or `changed`; old `.blend/specs/` untouched.

- [ ] **Step 4: Execute one task and sync (brownfield)**

Continue the Step 3 subagent: "Execute task 1 with
superpowers:executing-plans. Then, to test the sync, run
blend:project-views' Sync after implementation now, although tasks
remain." Expected: task 1's node `:state :done`; `views/modules.edn`
re-derived and clean; the report lists the slice changes owned by the
unfinished tasks as "planned, not happened" and nothing task 1 did as
unplanned; `views/architecture.edn` gains the slice's new elements without
`:change`/`:kind`/`:tasks`. Discard the scratch repo afterwards.

- [ ] **Step 5: Open the brownfield plan graph yourself**

Serve it (`simpleviz <snapshot>/.blend/<plan>.edn --no-open`), follow a
task's `:md-ref` (`f m`) and a pair into the modules slice (`f p`).
Expected: both open; the slice shows the task in the inspector's pairs.

- [ ] **Step 6: Fix and re-run**

For every expectation missed in Steps 2–5: fix the responsible skill or
template (smallest wording change), re-run that step. Record each fix in
the commit message.

- [ ] **Step 7: Commit the fixes**

```bash
git add plugins/blend
git commit -m "fix: issues found in the end-to-end dry run"
```

(No commit when Steps 2–5 passed first time; say so in the task report.)

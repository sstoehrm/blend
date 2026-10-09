---
name: brainstorming
description: Use when brainstorming, designing, or writing a spec for any feature or idea — load this instead of loading superpowers:brainstorming directly.
---

# Brainstorming (blend)

Runs superpowers:brainstorming, with the design kept as simpleviz graphs
and a short `overview.md` instead of a spec document; planning continues
in blend:planning. Load superpowers:brainstorming now and follow it at the
involvement level the user picks below. The steps below amend that
process; they do not replace it.

## Involvement level

Your first question, before any other, asks how involved the user wants
to be — multiple choice (use the host's question tool if it has one). It
goes in the same message that announces the path classification.

- **High** — the full superpowers process, every question and gate.
- **Medium** — only questions that change the design, one design review
  (overview + views), then plan review.
- **Full auto** — you decide everything and run through implementation.

Skip the question when the request already names a level ("full auto",
"just decide", "ask me everything"); state the level you took instead.
The level holds until the user changes it.

The chosen level is the user's explicit instruction about the process,
so it overrides the ask-and-wait rules of superpowers and use-blend as
listed here. Under full auto the user has approved every stage in
advance; "a reply approves the stage actually presented" does not apply.

| Step                           | High       | Medium                                                                                                       | Full auto                                         |
| ------------------------------ | ---------- | ------------------------------------------------------------------------------------------------------------ | ------------------------------------------------- |
| Clarifying questions           | as written | only those whose answer changes the design and the repo can't answer; the rest become stated assumptions     | none; decide, record assumptions in overview.md  |
| Write-back, approaches, design | as written | one message: understanding, approaches with recommendation, whole design; one approval                       | no stop                                           |
| Visual companion               | as written | as written                                                                                                   | never offer                                       |
| Design review (overview + views) | stop       | stop                                                                                                         | no stop                                           |
| Plan review + execution method | stop       | stop                                                                                                         | no stop; pick subagent-driven if available        |
| Worktree consent               | as written | as written                                                                                                   | no stop; create the worktree                      |
| Finishing menu                 | stop       | stop                                                                                                         | no stop; keep the branch, never merge or push     |

On a bounded or spike path, the short design or probe approval is the
"design" row; rows for steps the path doesn't have don't apply.

Full auto also:

- Creates the worktree before its first file or commit, so nothing lands
  on the user's checked-out branch.
- Turns every other ask in a downstream skill (failing baseline tests, a
  missing simpleviz, an unclear base branch) into a decision it logs.
- Ends with a report: what was built, every decision made, and the
  plan graph path.

Every level still stops for the execution blockers superpowers lists:
destructive or security-sensitive actions, side effects outside the
worktree, a plan too broken to guess past.

## Amendments

**1. Refresh the project views first.** Right after announcing the path,
before clarifying questions: **REQUIRED SUB-SKILL:** blend:project-views.
Re-derive `.blend/views/modules.edn` (create it if missing). If
`.blend/views/architecture.edn` is missing in a project with code, draw
the parts this feature touches. Greenfield: create both from their
templates, emptied. Ignore `.blend/specs/` — files from blend's earlier
format, history only. On a spike path, skip the refresh.

**2. Draw the design as plan views.** At "Present design" (architectural
path), with `<plan>` = `YYYY-MM-DD-<topic>`. **REQUIRED SUB-SKILL:**
simpleviz:simpleviz.

- `.blend/<plan>/architecture.edn` and `.blend/<plan>/modules.edn`, each
  from `simpleviz init <file> -t blend-plan-view`: what the design
  touches plus direct neighbours. `:type` is `new`, `changed`, `removed`
  or `context`; the element's own type goes in `:kind`; `:change` says
  what changes in one line; existing elements `:pair` to
  `"../views/<file>#<id>"`. New modules get the id the derive will give them
  (module name made EDN-safe).
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
  be skipped; say so in overview.md and delete the :architecture node from the
  plan graph.
- The plan views are independent of superpowers' visual companion; they
  are drawn whether or not the user accepted it.

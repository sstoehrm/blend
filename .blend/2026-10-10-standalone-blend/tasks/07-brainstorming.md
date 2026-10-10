# Task 7: blend:brainstorming without superpowers

**Goal:** brainstorming carries its own process — paths, questions,
approaches, design, gates — keeps the three involvement levels, and
refreshes the views through blend:persist.

**Files:**
- Modify: `plugins/blend/skills/brainstorming/SKILL.md` (full rewrite below)

**Interfaces:**
- Consumes: `blend:persist` sources `git` and `session` (task 3),
  `blend:planning` (task 6), `blend:executing` (task 5) for full auto;
  `run.sh`, `setup.sh` (task 1).
- Produces: plan views, plan graph and overview.md in the 0.6.0 format.

- [ ] **Step 1: Write the scenarios**

| # | Fixture | Prompt | Pass |
| --- | --- | --- | --- |
| S2 | `cli-small` | `Load blend:brainstorming. I want due dates on todos.` | the reply classifies the path and asks the involvement level first; no files written; no other question in that reply |
| S3 | `empty` | `Load blend:brainstorming. Full auto. Build a Python CLI csv2json that converts a CSV file to a JSON array of objects (header row = keys), stdin/stdout when no file is given.` | `.blend/views/` with modules.edn, architecture.edn, system.md; plan graph with task nodes; both slices; overview.md with the plan sections; task files; tests pass; `/api/errors` clean for every `.edn`; no `docs/superpowers/`; finish = keep; `superpowers_uses=0` |
| S11 | `empty`, env `SIMPLEVIZ_HOME=$(mktemp -d)` | as S3 | as S3 — files written without templates are valid |
| S12 | `cli-small` | `Load blend:brainstorming. Full auto. Add a "done <n>" command.` | classified bounded: no plan graph, no overview; the command works with a test; ends with a persist (session) commit touching only `.blend/views/` |

- [ ] **Step 2: Run the baseline**

S2 and S3 with arm `new` against the 0.6.0 skill (before Step 3).
Expected: it tries superpowers:brainstorming (`superpowers_uses` ≥ 1 or
says it is missing). Record it.

- [ ] **Step 3: Rewrite SKILL.md**

````markdown
---
name: brainstorming
description: Use when brainstorming, designing, or writing a spec for a feature or idea, or before building something new with blend.
---

# Brainstorming (blend)

Turns an idea into an agreed design — plan views (simpleviz graphs), a
plan graph as entry point and a short overview.md — then a plan through
blend:planning. Until the design is approved at the chosen level: no
product code, scaffolding or installs. Reading the repo is fine.

## Involvement level

Your first message classifies the path (below) and asks how involved the
user wants to be — multiple choice, with the host's question tool if it
has one:

- **High** — every question and gate below.
- **Medium** — only questions that change the design; one design review
  (overview + views), then plan review.
- **Full auto** — you decide everything and run through implementation.

Skip the question when the request names a level ("full auto", "just
decide", "ask me everything"); state the level you took. It holds until
the user changes it, and overrides blend's other ask-and-wait rules as
listed here. Under full auto every stage is approved in advance.

| Step | High | Medium | Full auto |
| --- | --- | --- | --- |
| Clarifying questions | one at a time | only those the repo can't answer that change the design; the rest become stated assumptions | none; assumptions go in overview.md |
| Understanding, approaches, design | each its own stop | one message, one approval | no stop |
| Design review (overview + views) | stop | stop | no stop |
| Plan review + execution mode | stop | stop | no stop; subagent per task if available |
| Worktree | ask | ask | create it before the first file |
| Finish menu | stop | stop | keep the branch; never merge or push |

Full auto also turns every other ask in blend's skills into a logged
decision and ends with a report: what was built, every decision, the
plan graph path. Every level stops for destructive or security-sensitive
actions and side effects outside the repo.

## Path

Classify before the first question and say it, so the user can override:

- **Spike** — a feasibility question; the output is an answer. State the
  question and the probe in 2–3 sentences, get a nod, investigate
  cheaply, report a recommendation. Anything built is throwaway. No files.
- **Bounded** — a well-scoped change to a flow that already exists in
  this repo. Ask what matters, present a short design in chat (approach,
  files, tests), stop for a yes, implement with TDD, then blend:persist
  with source session. No plan files.
- **Architectural** — new projects, subsystems, changed interfaces or
  structure: the process below.

In doubt, take the heavier path. Complexity found mid-task upgrades the
path; say so.

## Architectural process

1. **Refresh** — blend:persist with source git (it creates missing views;
   greenfield gets empty ones).
2. **Explore** — files, docs, recent commits, the project views. Several
   independent subsystems: say so, split, design the first.
3. **Understand** — ask about purpose, constraints and success criteria,
   one question per message, multiple choice when possible. Then write
   back what the user said and what you assume, and let them correct it.
4. **Approaches** — 2–3 with trade-offs, your recommendation first. YAGNI.
5. **Design** — architecture, components, data flow, error handling,
   testing, each section as long as its complexity needs. Units with one
   purpose and clear interfaces; in existing code, follow its patterns
   and improve only what the work touches. Draw the plan views as you
   present and revise them as the design changes.
6. **overview.md** — write it, self-review, commit.
7. **Design review** — give the plan graph URL and the overview path.
8. **Plan** — load blend:planning. Nothing else follows brainstorming.

## Plan views

`<plan>` = `YYYY-MM-DD-<topic>`. **REQUIRED SUB-SKILL:** simpleviz:simpleviz.

- `.blend/<plan>/architecture.edn` and `.blend/<plan>/modules.edn`: what
  the design touches plus direct neighbours. `:type` is `new`, `changed`,
  `removed` or `context`; the element's own type goes in `:kind`;
  `:change` is one line; existing elements `:pair` to
  `"../views/<file>#<id>"`; new modules get the id a derive would give
  (module name made EDN-safe). Example node:
  `:exporter {:name "app.export" :type "new" :kind "app" :change "writes CSV"}`.
- `.blend/<plan>.edn`, the entry point: nodes `:overview {:name "Overview"
  :type "doc" :md-ref "<plan>/overview.md"}`, `:architecture` and
  `:modules` (`:type "view"`, `:ref "<plan>/<file>.edn"`), `:proj-arch`
  and `:proj-modules` (`:ref "views/<file>.edn"`); a box `:design` around
  the first three.
- Templates are a shortcut: `simpleviz init <file> -t blend-plan-view` or
  `-t blend-plan`, then replace the example content.
- Serve the plan graph in the background (`simpleviz .blend/<plan>.edn
  --no-open`) and give the user the URL.

## overview.md

`.blend/<plan>/overview.md`: Goal, Decisions, Behavior or Workflow as the
design needs, Non-goals, Success criteria, Testing, Open points.

Self-review, fixing inline: no placeholders or TBDs; no contradictions;
one plan's worth of scope; every requirement has one reading. With the
plan graph served, `curl -s "$URL/api/errors?file=<path>"` prints no
warnings for each file. Commit the plan graph, the plan folder and
`.blend/views/` together.

## Judgment

- Views show structure. Requirements, trade-offs and open questions go
  in overview.md.
- The modules slice is always drawn. An architecture slice with fewer
  than ~3 touched components may be skipped; say so in overview.md and
  delete the `:architecture` node.

Adapted from superpowers:brainstorming by Jesse Vincent (MIT).
````

- [ ] **Step 4: Run the scenarios**

S2, S3, S11, S12 with arm `new`. Expected: the pass column. `wc -l` ≤ 150.

- [ ] **Step 5: Commit**

```sh
git add plugins/blend/skills/brainstorming
git commit -m "feat: blend:brainstorming carries its own process; refresh via persist"
```

---
name: onboarding
description: Use when someone new should be walked through the project — an onboarding presentation, intro deck, project tour or slides built from blend's spec (.blend intro, features, architecture and module graphs).
---

# Onboarding

Turns `.blend/` into a slide deck, `.blend/onboarding.md`, that simpleviz
presents with the real graphs beside the slides. **REQUIRED SUB-SKILL:**
simpleviz:simpleviz for md pages. Presenting needs simpleviz ≥ v0.40.0.

## Start

1. `.blend/views/` or `.blend/features/` exists, or one of intro.md,
   features.md, architecture.edn, modules.edn is missing: load
   blend:persist first, never write them yourself.
2. Read all four. Audience from the request; default a new developer.
   Don't ask. The deck is derived: a rerun overwrites it, and nothing
   else keeps it current.

## Slide format

Slides are split at lines of just `---`; the first slide is the title.
A slide whose first non-blank line is `>> [<label>](<file>)` shows that
graph or md file on the right, the slide text on the left. One side per
slide; paths are siblings in `.blend/` (`architecture.edn`), never with
`#id` — name the ids in the text instead. Keep a slide to a heading and
at most ~6 bullets or a short table.

## The deck

In this order; skip a slide that would be empty:

1. **Title** — project name, one line on what it is.
2. **What and for whom** — from intro.md, a few bullets.
3. **Architecture** — `>> [Architecture](architecture.edn)`: the main
   components and the flows between them, in reading order.
4. **One slide per top-level box** (subsystem), `>> architecture.edn`:
   what it does, its components, what it talks to. More than ~6 boxes:
   group the small ones.
5. **Modules** — `>> [Modules](modules.edn)`: how the code is laid out,
   the entry points (modules nothing imports, or `main`), where to start
   reading. Grep the code to confirm entry points and the test command.
6. **One slide per built feature** of features.md, `>> architecture.edn`
   (or `modules.edn` when it only touches modules): what it does for the
   user, an example, the `Touches:` ids as "where it lives". More than
   ~8: group related ones.
7. **Planned** — every `Status: planned` feature, one line each, its
   planned (`:state :new`) parts named; omit when none.
8. **How we work** — run the tests, then blend: ideas go through
   blend:brainstorming into `.blend/`, blend:build implements the spec
   diff, blend:persist keeps the graphs true.
9. **Where to go next** — `>> [Intro](intro.md)`: features.md, the
   graphs, first files to read.

Every statement comes from `.blend/` or code you read; nothing invented.
A server already serving `.blend/onboarding.md`: take its lock first.

## Check, serve, commit

1. `simpleviz check .blend/onboarding.md` prints `ok` (it checks the `>>`
   links); fix and repeat until it does.
2. Serve `simpleviz .blend/onboarding.md --no-open` in the background;
   give the user the URL and say: Present, top right; → and ← step.
3. Commit only the deck — `git add .blend/onboarding.md && git commit
   -m "docs: onboarding deck" -- .blend/onboarding.md`. The pathspec
   keeps the user's staged work out. Unchanged deck: no commit.

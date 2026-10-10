# Standalone blend: opt-in skills, no superpowers, persist

## Goal

Blend works on its own: no superpowers dependency, no workflow forced on
the user, and a `persist` skill that folds session work or git history
into a global spec (`.blend/views/`). Brainstorming keeps its three
involvement levels and still produces plan views, plan graph,
overview.md and task files.

## Background

- Blend 0.6.0 loads superpowers for brainstorming, planning, execution,
  TDD, debugging, review and finishing: about 3,700 lines of skill text
  behind blend's 474.
- Skill studies from 2026 (notes in the session; sources:
  arXiv 2608.11888, 2608.23067, 2607.03048, SkillsBench 2602.12670,
  SWE-Skills-Bench 2603.15401): most skill-induced cost comes from
  excessive procedure (verification, heavy pipelines), not length alone;
  examples and templates get treated as requirements; shortening a skill
  extractively did not lower pass rate; length alone hurts Sonnet.
- superpowers is MIT (Copyright (c) 2025 Jesse Vincent). Adapted text
  must carry the copyright and permission notice.
- Blend's own scenario tests so far measured format compliance, not
  outcome against a no-blend control.

## Decisions

1. **Workflow is opt-in.** use-blend stays always-loaded for style,
   verification, TDD and review rules. When a request fits a blend skill
   it offers it in one line; the skill runs on yes or when the user names
   it. No phase is routed automatically.
2. **No superpowers.** Blend never loads a superpowers skill. Each
   touchpoint gets a blend home:

   | superpowers | blend |
   | --- | --- |
   | using-superpowers | use-blend's opt-in offers (no forced skill check) |
   | brainstorming | blend:brainstorming, self-contained |
   | writing-plans | blend:planning, self-contained |
   | subagent-driven-development, executing-plans | blend:executing, two modes |
   | using-git-worktrees | two lines in blend:executing (and full auto) |
   | finishing-a-development-branch | blend:executing's finish step |
   | verification-before-completion | use-blend rule (exists) + executing's finish step |
   | test-driven-development | use-blend section + planning's task structure |
   | systematic-debugging | blend:debugging |
   | requesting-code-review | use-blend section + `executing/reviewer-prompt.md` |
   | receiving-code-review | use-blend section (verify each finding, push back with evidence) |
   | writing-skills | not shipped; README notes how blend's skills are tested |
   | visual companion, dispatching-parallel-agents, diagnosing-superpowers | dropped |

3. **Adapt, don't copy whole.** Keep every step and gate; drop
   rationalization and red-flag tables, long examples and repeated
   warnings. Each adapted SKILL.md ends with
   `Adapted from superpowers:<skill> by Jesse Vincent (MIT).`;
   `plugins/blend/THIRD_PARTY_NOTICES.md` carries the full license text.
4. **Line budgets** (SKILL.md, front matter included): use-blend ≤ 120
   (injected every session), brainstorming ≤ 150, planning ≤ 120,
   executing ≤ 150 plus reviewer-prompt.md ≤ 60, debugging ≤ 80,
   persist ≤ 120.
5. **persist absorbs project-views.** One skill owns the global spec;
   project-views is deleted. Sources:

   | Source | Range | Architecture | system.md |
   | --- | --- | --- | --- |
   | git | `<from>..HEAD`; from the marker, else the user's range, else none — describe the code as it is now | update components the diff touches; draw missing ones it touches | decisions from commit messages and changed docs |
   | session | changes made in this conversation, committed or not | as git | decisions made in the conversation |
   | plan | a finished plan | apply the architecture slice (0.6.0 sync rules) | the overview's Decisions that still constrain future work |

   Every source re-derives modules.edn from the working tree, reports
   one line per change (with a plan: unplanned changes and planned ones
   that didn't happen), sets the marker to HEAD, runs `simpleviz check`
   and commits only `.blend/views/` as `docs: persist project views`.
6. **system.md** is the text half of the global spec:
   `<!-- persisted-through: <sha> -->`, then `# System`, `## Purpose`,
   `## Constraints`, `## Decisions` (`- YYYY-MM-DD — decision — why —
   source`). A superseded decision is replaced, not appended; change logs
   stay in git.
7. **Brainstorming refresh = persist (git)** at the start (skipped on a
   spike). A bounded change ends with persist (session).
8. **blend:executing** reads the plan graph; task order comes from
   `needs` edges, the task file is the brief.
   - Inline (default): per task set `:in-progress`, follow the task
     file's TDD steps, run the tests, commit, set `:done`.
   - Subagent (on request, or ≥ 5 tasks with a subagent tool): one
     implementer per task (task file + overview's Global constraints),
     one reviewer per task with reviewer-prompt.md on `BASE..HEAD`;
     at most 2 fix rounds, then decide and log. Never parallel
     implementers.
   - After the last task: one whole-branch review on the most capable
     model, persist (plan), full test suite with its output, then the
     finish menu — merge locally / push + PR / keep — per involvement
     level.
   - Decisions taken during execution go to overview.md
     `## Execution log`; the plan graph's `:state` is the ledger.
9. **Templates optional.** Each skill states the minimal EDN shape it
   writes; `simpleviz init -t blend-…` is a shortcut. The hook still
   installs the templates.
10. **deduce is removed here** (it overlaps persist's trigger).
11. **Version 0.7.0**; manifests and marketplace descriptions drop
    "superpowers".

## Workflow

session → use-blend (rules) → one-line offer → on yes:
blend:brainstorming (involvement → persist git → design process → plan
views + overview, gate 1) → blend:planning (tasks, gate 2) →
blend:executing (tasks → final review → persist plan → verify →
finish). Outside a plan: blend:debugging for bugs, blend:persist on
request. See `architecture.edn`.

## Non-goals

- Feature parity with superpowers' process depth (SDD ledgers, review
  packages, five fix rounds).
- Supporting superpowers alongside blend for the same phase. If both
  are installed, blend's skills replace their counterparts when the
  user opts into blend.
- A visual companion; plan views cover diagrams.
- Migrating 0.6.0 plans or `.blend/specs/`.

## Success criteria

- No "superpowers" in `plugins/blend/` outside THIRD_PARTY_NOTICES.md and
  the "Adapted from" lines.
- Every SKILL.md within its line budget.
- All scenarios below pass in the isolation harness.
- Outcome comparison: 0.7.0 alone is not worse than 0.6.0 +
  superpowers on pass rate, and uses fewer tokens. If it is worse, the
  numbers go to the user before merge.

## Testing

**Isolation harness** (checked 2026-10-10: lists only blend skills):

```sh
claude -p --model sonnet \
  --settings '{"enabledPlugins":{"superpowers@claude-plugins-official":false,"blend@blend":false}}' \
  --plugin-dir <worktree>/plugins/blend --output-format stream-json "<scenario>"
```

Each transcript is grepped for `superpowers` (must be absent). Baseline =
the same scenario on 0.6.0 with superpowers enabled.

| # | Scenario | Pass |
| --- | --- | --- |
| S1 | "add CSV export to this CLI" in a small repo | one-line offer, no skill run |
| S2 | brainstorm, first turn | asks the involvement level first |
| S3 | brainstorm full auto, greenfield | views, plan graph, overview, tasks; `/api/errors` clean |
| S4 | planning from T4's approved design | task files, nodes, needs-edges, `:tasks` on slices |
| S5 | executing inline, 2-task plan | TDD commits, `:state` done, persist (plan), finish = keep |
| S6 | executing subagent mode | one implementer + one reviewer per task, final review |
| S7 | debugging, failing-test fixture | regression test before the fix |
| S8 | persist git, smpl-blackboard range | modules re-derived, system.md decisions, marker = HEAD |
| S9 | persist session after an ad-hoc change | views + system.md; user's code not committed by persist |
| S10 | persist plan, T3 C fixture | unplanned module reported, slice applied |
| S11 | S3 with an empty `SIMPLEVIZ_HOME` | same files, valid without templates |

**Outcome comparison:** greenfield CSV→JSON and brownfield
smpl-blackboard due dates, full auto end to end, 3 runs per arm
(0.6.0 + superpowers, 0.7.0 alone), Sonnet. Score: acceptance tests
written before the runs, tokens, turns, wall time.

## Open points

- This branch is stacked on unmerged PR #4: its PR targets
  `claude/graph-native-plans` or waits for #4.
- The uncommitted deduce deletion in the main checkout becomes
  redundant; discard it there once this lands.
- The outcome comparison costs about 12 end-to-end runs; it can shrink
  to 1 run per arm if that is too much.

## Plan

Tech stack: markdown skills, POSIX sh, `jq`, the `claude` CLI headless
(`-p --settings --plugin-dir --output-format stream-json`), simpleviz
≥ 0.32.0, Python 3 stdlib for fixtures. Nine tasks; after task 2, tasks
3, 4 and 6 are independent. Task files: `tasks/01-harness.md` …
`tasks/09-outcome.md`.

## Global constraints

- Line budgets (whole file): use-blend ≤ 120, brainstorming ≤ 150,
  planning ≤ 120, executing ≤ 150, executing/reviewer-prompt.md ≤ 60,
  debugging ≤ 80, persist ≤ 120.
- Adapted files end with `Adapted from superpowers:<skill>[, <skill>…]
  by Jesse Vincent (MIT).` — brainstorming, planning, executing,
  reviewer-prompt.md, debugging. Nowhere else in `plugins/blend/` names
  superpowers, except THIRD_PARTY_NOTICES.md.
- Skill names: `blend:brainstorming`, `blend:planning`, `blend:executing`,
  `blend:debugging`, `blend:persist`; persist sources `git`, `session`,
  `plan`; persist commit message `docs: persist project views`.
- Version 0.7.0; template line 1 `;; blend-template 0.7.0`.
- Scenarios run through `tests/scenarios/run.sh`, model sonnet, prompts
  verbatim from the task files, in temp dirs from `setup.sh`. Never
  `pkill`/`killall`; stop only processes you started, by PID.
- A failing scenario: tighten the skill text, re-run; after 2 re-runs
  still failing, record it in the Execution log and decide.
- `.blend/views/` is not edited by hand; persist (plan) updates it after
  the last task.

## Review focus

1. persist git on a repo with no marker and a long history: describes the
   code as it is and reads commit messages selectively, not every commit
   — S8 (task 3).
2. persist session with the user's uncommitted code: the code stays
   uncommitted, only `.blend/views/` is committed — S9 (task 3).
3. executing after an interruption: resumes at the first task not
   `:done`, doesn't redo finished tasks — S5b (task 5).
4. superpowers and blend both installed, user opts into blend: blend's
   skill runs, not superpowers' — S1b (task 2).
5. no templates installed: brainstorming still writes valid views and
   plan graph — S11 (task 7).

## Executing this plan

Plan graph: `.blend/2026-10-10-standalone-blend.edn`. This plan builds
blend:executing, so it runs on the tools installed today:
superpowers:subagent-driven-development, with each task file as the
task's brief (skip SDD's `task-brief` and `task-start` scripts; PLAN_FILE
is the plan graph). Task order follows the graph's `needs` edges; tasks
without a path between them are independent. Set the task node's
`:state`: `:in-progress` when started, `:done` once its review is clean,
`:blocked` with `:reason "<why>"`. Implementers run their task's
scenarios themselves through `tests/scenarios/run.sh` (a shell command,
not a subagent). After the last task, load this branch's
`plugins/blend/skills/persist/SKILL.md` and persist this plan (source
plan) into `.blend/views/`.

# Task 2: use-blend — opt-in offers, own rules, no superpowers

**Goal:** the always-loaded skill offers blend's skills instead of
routing every phase, and carries TDD, verification and review rules
itself.

**Files:**
- Modify: `plugins/blend/skills/use-blend/SKILL.md` (full rewrite below)
- Modify: `plugins/blend/skills/use-blend/references/codex-tools.md`

**Interfaces:**
- Consumes: skill names fixed by this plan: `blend:brainstorming`,
  `blend:planning`, `blend:executing`, `blend:debugging`, `blend:persist`;
  the file `reviewer-prompt.md` beside blend:executing's SKILL.md (task 5).
- Produces: sections `## Blend skills (opt-in)`, `## Test-Driven
  Development`, `## Verification`, `## Code Review` that other skills name.

- [ ] **Step 1: Write the scenario prompts**

S1 (offer, not run), fixture `cli-small`, prompt file `s1.txt`:

```
Add a "done <n>" command to this todo CLI that marks item n as done.
```

S1b (both installed, user opts in), fixture `cli-small`, arm `mixed`,
prompt file `s1b.txt`:

```
Use blend for this: add a "done <n>" command to this todo CLI. Stop after your first question.
```

Pass S1 (arm new): the result offers blend:brainstorming (or blend's
bounded path) in one line or asks a clarifying question; no Skill tool
call in the transcript before the user answers; `superpowers_uses=0`.
Pass S1b: the first Skill call, if any, is `blend:brainstorming`, not
`superpowers:brainstorming`.

- [ ] **Step 2: Run the baseline**

`run.sh old` on S1. Expected (the 0.6.0 routing): it loads
blend:brainstorming or superpowers:brainstorming without offering.
Record the summary line and the first Skill call.

- [ ] **Step 3: Rewrite SKILL.md**

````markdown
---
name: use-blend
description: Use when starting any coding, design, debugging, or writing task — sets communication style, verification, TDD and review habits, and offers blend's opt-in skills when a request fits one.
---

# Use Blend

How to work, and which blend skill to offer. Blend's skills are opt-in:
when a request fits one, offer it in one line and run it only when the
user says yes or names it. Otherwise work directly with the rules below.

## Platform Adaptation

If your host appears here, read its reference first:

- Codex: [references/codex-tools.md](references/codex-tools.md)

## Dependencies

Check lazily, right before the first step that needs one. If one is
missing, give the user the fix and wait; work without it only if they
decline.

| Dependency         | Needed by                        | Check                             | Fix |
| ------------------ | -------------------------------- | --------------------------------- | --- |
| simpleviz skill    | brainstorming, planning, persist | simpleviz skill in the skill list | `/plugin install simpleviz@simpleviz`, or the host's method from [simpleviz](https://github.com/sstoehrm/simpleviz) |
| simpleviz launcher | same                             | `simpleviz --version` ≥ v0.32.0   | `curl -fsSL https://raw.githubusercontent.com/sstoehrm/simpleviz/main/install.sh \| bash`; older: `simpleviz update` |
| babashka           | simpleviz                        | `command -v bb`                   | https://github.com/babashka/babashka#installation |

blend's SessionStart hook installs its simpleviz templates (`blend-plan`,
`blend-architecture`, `blend-modules`, `blend-plan-view`); the skills
work without them.

## Blend skills (opt-in)

| Request | Offer |
| --- | --- |
| New feature, idea or design | blend:brainstorming — design as graphs + overview.md, then a task graph |
| An approved blend design needs a plan | blend:planning |
| A blend plan graph is ready to run | blend:executing |
| Bug, failing test, unexpected behavior | blend:debugging |
| "Update the spec", or ad-hoc changes worth keeping in `.blend/views/` | blend:persist |

One offer per request, e.g. "New feature — run blend:brainstorming
(design graphs + task graph)? Otherwise I'll ask what I need and start."
A no holds for that request. When the user opts into blend, blend's skill
replaces any other plugin's skill for the same phase.

## Communication Style

- Concise and direct. No filler praise, no hedging, no sycophancy. Dry wit
  is fine; snark is not.
- Explanations: max 3 paragraphs. If the explanation is longer than the
  code, cut the explanation, not the code.
- Always use tables for comparisons.
- Disagree openly. If the request is over-built or ambiguous, say so and
  present the interpretations — never pick one silently.

## Verifying Knowledge

Never "know" — always verify:

- Unfamiliar APIs/libraries: fetch current docs before writing code
  against them. Training memory is stale by default.
- Dependencies: look up the newest version online before pinning or
  recommending one.
- Claims about this codebase: grep/read first, assert second.

## Minimal Code

1. **Think before coding.** State assumptions. Several interpretations →
   present them. Unclear → ask.
2. **Simplicity ladder** — stop at the first rung that holds: not needed
   (YAGNI) → reuse what's in the repo → stdlib → native platform feature
   → installed dependency → one line → minimal new code.
3. **Surgical changes.** Every changed line traces to the request. Match
   existing style. Remove only orphans your change created.

Never simplify away: validation at trust boundaries, error handling that
prevents data loss, security, accessibility, anything requested.

## Test-Driven Development

For code with behavior: write the failing test, run it and see it fail
for the expected reason, write the minimal code that passes, run the
tests, refactor while green. A test that passes before the change proves
nothing. A bug fix starts with a test that reproduces the bug. Config,
generated code and throwaway spikes are exempt — say so.

## Verification

Before saying done, fixed or passing: run the command that proves it in
this turn and show its result. Without that, say what is unverified.

## Code Review

One read-only reviewer (a subagent if the host has one) gets the
requirements, the exact scope (a commit range; for uncommitted work the
staged, unstaged and relevant untracked changes) and the reviewer prompt
`reviewer-prompt.md` beside blend:executing's SKILL.md. No other review
commands chained; broader audits need a user request.

Receiving review: check each finding against the code before changing
anything; fix what holds, push back with evidence on what doesn't, ask
when one is unclear. Re-run the affected tests after fixing; reuse a
review while its diff is unchanged.
````

- [ ] **Step 4: Edit codex-tools.md**

Delete the sentence "Use the installed Superpowers platform guidance for
Superpowers workflows." Replace "Resolve names such as
`blend:brainstorming` by plugin and skill so they aren't confused with
`superpowers:brainstorming`." with "Resolve names such as
`blend:brainstorming` by plugin and skill, not by skill name alone."
Delete the `**superpowers:**` install bullet; the list keeps the
simpleviz bullet.

- [ ] **Step 5: Verify**

`wc -l plugins/blend/skills/use-blend/SKILL.md` ≤ 120;
`grep -ri superpowers plugins/blend/skills/use-blend` prints nothing.
Run S1 (arm new) and S1b. Expected: the pass criteria from Step 1.

- [ ] **Step 6: Commit**

```sh
git add plugins/blend/skills/use-blend
git commit -m "feat: use-blend offers blend skills and carries its own rules"
```

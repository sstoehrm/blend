---
name: use-blend
description: Use when starting any coding, design, debugging, or writing task — sets communication style, verification, TDD, debugging and review habits, and offers blend's opt-in skills when a request fits one.
---

# Use Blend

How to work. Blend's skills are opt-in: when a request fits one, offer it
in one line and run it only when the user says yes or names it.

| Request | Offer |
| --- | --- |
| An idea, a feature to think through, "let's talk about …" | blend:brainstorming — collect it into feature files and the graphs |
| "Build it", spec changes ready to implement | blend:build — implements what changed in `.blend/` since the last build, in one full-auto run |
| "Update the graphs", work done outside blend | blend:persist |

A no holds for that request. Blend skills that name each other load
each other without asking. Codex: read
[references/codex-tools.md](references/codex-tools.md) first; Grok:
[references/grok-tools.md](references/grok-tools.md).

The skills need simpleviz; check right before the first use, and if one is
missing give the fix and wait:

| Dependency | Check | Fix |
| --- | --- | --- |
| simpleviz skill | in the skill list | `/plugin install simpleviz@simpleviz` ([simpleviz](https://github.com/sstoehrm/simpleviz)) |
| simpleviz launcher | `simpleviz --version` ≥ v0.34.0 | `curl -fsSL https://raw.githubusercontent.com/sstoehrm/simpleviz/main/install.sh \| bash`; older: `simpleviz update` |
| babashka | `command -v bb` | https://github.com/babashka/babashka#installation |

## Style

- Concise and direct. No filler praise, hedging or sycophancy.
- Explanations: max 3 paragraphs. Tables for comparisons.
- Disagree openly. Ambiguous or over-built request: say so and present
  the readings — never pick one silently.

## Working

- **Verify, don't know.** Fetch current docs for unfamiliar APIs, look up
  the newest version before pinning one, grep before claiming anything
  about the codebase.
- **Minimal code.** Not needed → reuse → stdlib → platform → installed
  dependency → new code; stop at the first that holds. Every changed line
  traces to the request. Never simplify away validation at trust
  boundaries, data-loss handling, security or accessibility.
- **TDD** for code with behavior: failing test, see it fail for the right
  reason, minimal code, see it pass, refactor while green.
- **Debugging:** reproduce first, as a failing test when possible. Find
  the root cause before changing code — read the error, trace the bad
  value back to where it starts, one hypothesis at a time. Fix the cause,
  not the symptom; the reproducing test stays. Three failed fixes: stop
  and question the approach.
- **Done means shown.** Before saying done, fixed or passing, run the
  command that proves it and show the result; otherwise say what is
  unverified.

## Review

One read-only reviewer (a subagent if the host has one, strong tier —
see blend:build) gets the
requirements, the exact scope (a commit range; uncommitted work: staged,
unstaged and relevant untracked changes) and blend's
`skills/build/reviewer-prompt.md`. Receiving review: check each finding
against the code; fix what holds, push back with evidence on what
doesn't. Re-run affected tests after fixing.

Adapted from superpowers:test-driven-development, systematic-debugging
and requesting-code-review by Jesse Vincent (MIT).

---
name: use-blend
description: Use when starting any coding, design, debugging, or writing task — before clarifying questions, exploration, or implementation. Establishes communication style, verification habits, and which skill to route each phase of work through.
---

# Use Blend

How to work and which skill to route each phase through. Blend skills blend
multiple skills into one workflow. Always prefer the most specific available
skill over improvising; if a referenced skill is not installed on this
machine, apply its core principle inline instead.

Where this overlaps with superpowers' using-superpowers routing, this skill
supersedes it: brainstorming always goes through blend:brainstorming (which
itself loads superpowers:brainstorming), never superpowers:brainstorming
directly.

## Platform Adaptation

If your host appears here, read its reference before following the workflow:

- Codex: [references/codex-tools.md](references/codex-tools.md)

## Dependencies

Check lazily — verify a dependency right before the first phase that needs
it, not at session start. If one is missing, give the user the fix below
and wait; fall back to inline principles only if they decline to install.

| Dependency         | Check                             | Fix                                                                                                                  |
| ------------------ | --------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| superpowers skills | superpowers skills in the skill list | `/plugin install superpowers@claude-plugins-official`, or the current host's installation method from [superpowers](https://github.com/obra/superpowers). |
| simpleviz skill    | simpleviz skill in the skill list | `/plugin install simpleviz@simpleviz`, or the current host's installation method from [simpleviz](https://github.com/sstoehrm/simpleviz). |
| simpleviz launcher | `simpleviz --version`             | `curl -fsSL https://raw.githubusercontent.com/sstoehrm/simpleviz/main/install.sh \| bash`; later: `simpleviz update` |
| babashka           | `command -v bb`                   | https://github.com/babashka/babashka#installation                                                                    |

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

- Unfamiliar APIs/libraries: fetch current docs (WebFetch/WebSearch or the
  host's equivalent web tools) before writing code against them. Training
  memory is stale by default.
- Dependencies: look up the newest version online before pinning or
  recommending one.
- Claims about this codebase: grep/read first, assert second.

## Minimal Code

1. **Think before coding.** State assumptions explicitly. Multiple
   interpretations → present them. Unclear → stop and ask.
2. **Simplicity ladder** — stop at the first rung that holds:
   not needed at all (YAGNI) → reuse what's already in the repo → stdlib →
   native platform feature → already-installed dependency → one line →
   minimal new code. No abstractions for single-use code, no speculative
   flexibility.
3. **Surgical changes.** Every changed line traces to the request. Match
   existing style. Remove only orphans your own change created.
4. **Goal-driven execution.** Turn every task into verifiable success
   criteria ("fix the bug" → "write a failing test, make it pass") and loop
   until verified. Never claim done without running the check.

Never simplify away: validation at trust boundaries, error handling that
prevents data loss, security, accessibility, anything explicitly requested.

## Code Review

Use superpowers:requesting-code-review for both working changes and PRs.
Give one read-only reviewer the requirements and exact review scope. For
uncommitted work, include staged, unstaged, and relevant untracked changes;
commit SHAs alone omit them. Inspect surrounding code as needed to verify
findings.

Cover correctness, regressions, requirements, concrete security issues,
and unnecessary complexity in that pass. Report actionable findings with
evidence and severity; style preferences aren't blockers. Do not
automatically chain built-in review, simplification, or security-review
commands. Broader audits require a user request or a concrete unresolved
finding.

Handle feedback through superpowers:receiving-code-review. Recheck fixes
and affected behavior; reuse a completed code review while its diff remains
unchanged instead of starting another full review at each workflow step.

## Workflow → Skill Routing

| Phase                   | Route through                                                                                                                         | Loop until                               |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------- |
| New feature / idea      | blend:brainstorming (loads superpowers:brainstorming, adds spec figure)                                                               | design agreed with user                  |
| Architecture overview   | blend:deduce                                                                                                                          | user confirms concept graph              |
| Writing/editing a skill | superpowers:writing-skills                                                                                                            | subagent tests pass                      |
| Design + mock-ups       | blend:brainstorming, then artifact-design / dataviz for the mock-up                                                                   | reviewer satisfied                       |
| Spec                    | superpowers:writing-plans                                                                                                             | reviewer satisfied                       |
| Implementation plan     | plan mode + superpowers:writing-plans                                                                                                 | reviewer satisfied                       |
| Implementation          | superpowers:executing-plans or subagent-driven-development, with test-driven-development                                              | tests green, per-task review clean       |
| Bug / failing test      | superpowers:systematic-debugging                                                                                                      | root cause found, regression test passes |
| Code review             | superpowers:requesting-code-review; superpowers:receiving-code-review for feedback                                                    | no blocking findings                     |
| Finishing               | superpowers:verification-before-completion, then finishing-a-development-branch                                                       | evidence shown, not asserted             |

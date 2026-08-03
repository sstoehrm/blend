---
name: use-my-skills
description: Use when starting any coding, design, debugging, or writing task — before clarifying questions, exploration, or implementation. Establishes communication style, verification habits, and which skill to route each phase of work through.
---

# Use My Skills

How to work and which skill to route each phase through. Always prefer the
most specific available skill over improvising; if a referenced skill is not
installed on this machine, apply its core principle inline instead.

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

- Unfamiliar APIs/libraries: fetch current docs (WebFetch/WebSearch) before
  writing code against them. Training memory is stale by default.
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

## Workflow → Skill Routing

| Phase                   | Route through                                                                                                                         | Loop until                               |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------- |
| New feature / idea      | superpowers:brainstorming                                                                                                             | design agreed with user                  |
| Writing/editing a skill | superpowers:writing-skills                                                                                                            | subagent tests pass                      |
| Design + mock-ups       | superpowers:brainstorming, then artifact-design / dataviz for the mock-up                                                             | reviewer satisfied                       |
| Spec                    | superpowers:writing-plans                                                                                                             | reviewer satisfied                       |
| Implementation plan     | plan mode + superpowers:writing-plans                                                                                                 | reviewer satisfied                       |
| Implementation          | superpowers:executing-plans or subagent-driven-development, with test-driven-development                                              | tests green, per-task review clean       |
| Bug / failing test      | superpowers:systematic-debugging                                                                                                      | root cause found, regression test passes |
| Code review             | /code-review for the working diff (/review for GitHub PRs), then /simplify; /security-review when auth, input, or secrets are touched | no blocking findings                     |
| Finishing               | superpowers:verification-before-completion, then finishing-a-development-branch                                                       | evidence shown, not asserted             |

Phases marked "reviewer satisfied" run the writer-reviewer-loop skill.

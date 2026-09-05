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

## Host Compatibility

These skills work in Claude Code and Codex. Use the tools actually available
in the current session; names below describe capabilities, not required APIs.

- **Load skills:** Claude Code uses its Skill tool. In Codex, select the
  installed skill or read its `SKILL.md` at the path in the skill list.
  Resolve names such as `blend:brainstorming` by plugin and skill, so it
  isn't confused with `superpowers:brainstorming`. For a direct file load,
  Blend's sibling skills are at `../<skill-name>/SKILL.md` relative to this
  skill's directory. Resolve external skills from the installed skill list.
- **Ask questions:** use the host's question tool when available in the
  current mode. Otherwise ask in ordinary chat and wait for the answer.
  If multiple selections aren't supported, present numbered choices and
  ask for the selected numbers. Preserve all user review gates.
- **Explore and review:** use the host's subagent tools when available.
  `Explore` means a read-only exploration task, not a required agent type.
  Without delegation, perform the same evidence checks directly in
  separate exploration and review passes; disclose that the review was
  not independent. Never claim a subagent review occurred when it didn't.
- **Browse and inspect:** use the host's web search/fetch and shell/file
  tools in place of Claude-specific tool names.
- **Code review:** in Claude Code, use the installed review commands in
  the routing table. In Codex, use its available review workflow or inspect
  the diff directly for correctness, simplification, and relevant security
  issues. Slash commands from another host are not shell commands.
- **Startup:** the plugin's SessionStart hook loads this skill in both
  hosts. If hooks are disabled or not trusted, explicitly select `use-blend`
  or ask the agent to read it before starting the task.

## Dependencies

Check lazily — verify a dependency right before the first phase that needs
it, not at session start. If one is missing, give the user the fix below
and wait; fall back to inline principles only if they decline to install.

| Dependency         | Check                             | Fix                                                                                                                  |
| ------------------ | --------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| superpowers skills | superpowers skills in the skill list | Claude Code: `/plugin install superpowers@claude-plugins-official`. Codex: install superpowers through its plugin browser, or follow the [repository's Codex instructions](https://github.com/obra/superpowers). |
| simpleviz skill    | simpleviz skill in the skill list | Claude Code: `/plugin install simpleviz@simpleviz`. Codex: use its skill installer with [the simpleviz repository](https://github.com/sstoehrm/simpleviz) and the directory containing the simpleviz `SKILL.md`. |
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

- Unfamiliar APIs/libraries: fetch current docs with the host's web tools before
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
| New feature / idea      | blend:brainstorming (loads superpowers:brainstorming, adds spec figure)                                                               | design agreed with user                  |
| Architecture overview   | blend:deduce                                                                                                                          | user confirms concept graph              |
| Writing/editing a skill | superpowers:writing-skills                                                                                                            | subagent tests pass                      |
| Design + mock-ups       | blend:brainstorming, then artifact-design / dataviz for the mock-up                                                                   | reviewer satisfied                       |
| Spec                    | superpowers:writing-plans                                                                                                             | reviewer satisfied                       |
| Implementation plan     | plan mode + superpowers:writing-plans                                                                                                 | reviewer satisfied                       |
| Implementation          | superpowers:executing-plans or subagent-driven-development, with test-driven-development                                              | tests green, per-task review clean       |
| Bug / failing test      | superpowers:systematic-debugging                                                                                                      | root cause found, regression test passes |
| Code review             | /code-review for the working diff (/review for GitHub PRs), then /simplify; /security-review when auth, input, or secrets are touched | no blocking findings                     |
| Finishing               | superpowers:verification-before-completion, then finishing-a-development-branch                                                       | evidence shown, not asserted             |

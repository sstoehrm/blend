---
name: writer-reviewer-loop
description: Use when producing a spec, plan, design, mock-up, or other artifact that must pass review before acceptance, or when dispatching writer/reviewer subagents.
---

# Writer–Reviewer Loop

A writer subagent produces the artifact; a reviewer subagent with fresh
context critiques it against the stated goal; the writer revises.

Stop when the reviewer has no blocking findings — or after 3 rounds, then
surface the remaining disagreement to the user instead of looping forever.
Blocking = wrong behavior, missed requirement, or security issue; style
preferences are never blocking.

## Model Selection for Subagents

| Task                                                    | Model  |
| ------------------------------------------------------- | ------ |
| Architecture, specs, adversarial review, hard debugging | Fable  |
| Default implementation, implementation plans            | Opus   |
| Well-specified, contained implementation tasks          | Sonnet |
| Mechanical edits, renames, search, formatting           | Haiku  |

Pass `model:` when dispatching subagents; when unsure, omit it and inherit
the session model.

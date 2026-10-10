<!-- persisted-through: 688475f309e68bc8c10827acd23369c1c6f51894 -->
# System

## Purpose
blend is a plugin for Claude Code and Codex that turns a feature request into design views, a task graph and finished, reviewed work, using simpleviz graphs as the shared artifact. It stands alone: no other plugin is required except simpleviz. Its workflow skills are opt-in; the always-loaded use-blend skill carries style, verification, TDD and review rules.

## Constraints
- Blend never loads a superpowers skill; text adapted from superpowers carries an "Adapted from" line and the MIT notice in plugins/blend/THIRD_PARTY_NOTICES.md.
- SKILL.md line budgets (front matter included): use-blend 120, brainstorming 150, planning 120, executing 150 (+ reviewer-prompt.md 60), debugging 80, persist 120.
- .blend/views/ is derived or persisted, never edited by hand; only persist commits it.

## Decisions
- 2026-10-10 — The workflow is opt-in: use-blend offers a blend skill in one line and the skill runs on yes or when named; no phase is routed automatically — forced routing cost more than it helped — 2026-10-10-standalone-blend
- 2026-10-10 — Each superpowers touchpoint has a blend home (brainstorming, planning, executing, debugging, persist, use-blend rules); adapted, not copied whole: steps and gates kept, rationalization tables and long examples dropped — less skill text, same procedure — 2026-10-10-standalone-blend
- 2026-10-10 — persist owns the global spec (modules.edn, architecture.edn, system.md) from a git range, a session or a finished plan; project-views and deduce are removed — one owner, no overlapping triggers — 2026-10-10-standalone-blend
- 2026-10-10 — blend:executing reads the plan graph, task order from needs edges, the task file is the brief; inline by default, a subagent per task on request or with 5 or more tasks; never parallel implementers; decisions go to overview.md Execution log — 2026-10-10-standalone-blend
- 2026-10-10 — Templates are optional: each skill states the minimal EDN shape it writes, the hook still installs the simpleviz templates — skills must work without them — 2026-10-10-standalone-blend
- 2026-10-10 — Version 0.7.0; manifests and marketplace descriptions no longer mention superpowers — 2026-10-10-standalone-blend

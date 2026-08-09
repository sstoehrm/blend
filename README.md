# blend

A Claude Code plugin that blends existing skills into one opinionated
workflow: [superpowers](https://github.com/obra/superpowers) drives the
process, [simpleviz](https://github.com/sstoehrm/simpleviz) makes designs
visible, and a session-start hook wires it all together. Packaged as a
plugin marketplace.

## Skills

| Skill              | What it does                                                                                                                                       |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| use-blend          | Injected into every session via SessionStart hook. Communication style, verification habits, dependency checks, and the phase → skill routing table. |
| blend:brainstorming | Wraps superpowers:brainstorming: draws the design as a live simpleviz figure while presenting it, keeps figure and spec in sync, folds the result into the concept graph. |
| blend:deduce       | Deduces and maintains a concept graph — a superficial architecture view of a project — from code, plans, or specs. Iterative: user approves concepts, a reviewer subagent validates every element against evidence. |

## The workflow

```
idea ──▶ blend:brainstorming ──▶ spec + figure ──▶ blend:deduce ──▶ concept graph
              │                     ▲                    │
              ▼                     └── misfit reopens ──┘
      superpowers:brainstorming            the spec
```

Brainstorming produces a spec document plus a simpleviz figure of the
design. After spec approval, deduce integrates the new components into the
project's concept graph — served in simpleviz compare mode so changes are
reviewed as a diff. The concept graph is a review gate: if the design
doesn't fit the architecture, the spec reopens. From there the normal
superpowers flow continues (writing-plans → implementation → review).

Artifacts land in the target project:

```
.blend/
├── specs/YYYY-MM-DD-<topic>.edn   # design figure per spec
├── concept.edn                    # the concept graph
└── concept-hash                   # repo commit the graph was last validated against
```

`concept-hash` scopes the next update: deduce diffs against it and only
re-explores what changed.

## Dependencies

| Dependency         | Install                                                                                   |
| ------------------ | ----------------------------------------------------------------------------------------- |
| superpowers plugin | `/plugin install superpowers@claude-plugins-official`                                     |
| simpleviz plugin   | `/plugin install simpleviz@simpleviz`                                                     |
| simpleviz launcher | `curl -fsSL https://raw.githubusercontent.com/sstoehrm/simpleviz/main/install.sh \| bash` |
| babashka           | https://github.com/babashka/babashka#installation                                         |

use-blend checks these lazily and tells you the fix when one is missing.

## Structure

```
.claude-plugin/marketplace.json     # marketplace catalog
plugins/blend/                      # the "blend" plugin
├── .claude-plugin/plugin.json
├── hooks/hooks.json                # SessionStart: injects use-blend
└── skills/
    └── <skill-name>/SKILL.md       # one directory per skill
```

## Usage

Add the marketplace and install the plugin:

```bash
claude plugin marketplace add sstoehrm/blend
claude plugin install blend@blend --scope user
```

Or in a Claude Code session:

```
/plugin marketplace add sstoehrm/blend
/plugin install blend@blend
```

The marketplace tracks GitHub, so picking up skill edits means publishing
them first:

```bash
git push                                        # publish the edits
claude plugin marketplace update blend          # pull them into the cache
```

Skills and the SessionStart hook register at session start — restart the
session (or `/clear`) after updating.

## Adding a skill

Create `plugins/blend/skills/<skill-name>/SKILL.md`:

```markdown
---
name: skill-name
description: Use when <triggering conditions — not a workflow summary>.
---

Instructions for Claude.
```

Follow superpowers:writing-skills: test the skill with fresh-context
subagents before deploying. Validate before committing:

```bash
claude plugin validate .
```

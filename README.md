# blend

A Claude Code and Codex plugin that blends existing skills into one opinionated
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

| Dependency         | Claude Code install                                                                       |
| ------------------ | ----------------------------------------------------------------------------------------- |
| superpowers plugin | `/plugin install superpowers@claude-plugins-official`                                     |
| simpleviz plugin   | `/plugin install simpleviz@simpleviz`                                                     |
| simpleviz launcher | `curl -fsSL https://raw.githubusercontent.com/sstoehrm/simpleviz/main/install.sh \| bash` |
| babashka           | https://github.com/babashka/babashka#installation                                         |

use-blend checks these lazily and tells you the fix when one is missing.

In Codex, install **superpowers** through the plugin browser or follow its
[Codex setup instructions](https://github.com/obra/superpowers). Install the
**simpleviz skill** using Codex's skill installer: provide
`https://github.com/sstoehrm/simpleviz` and select the directory containing
its `SKILL.md`. The simpleviz launcher and babashka are required in both
hosts. A Claude Code plugin installation alone doesn't make its skills
available to Codex.

## Structure

```
.claude-plugin/marketplace.json     # Claude Code marketplace catalog
.agents/plugins/marketplace.json   # Codex marketplace catalog
plugins/blend/                      # the "blend" plugin
├── .claude-plugin/plugin.json
├── .codex-plugin/plugin.json
├── hooks/hooks.json                # SessionStart: injects use-blend
└── skills/
    └── <skill-name>/SKILL.md       # one directory per skill
```

## Usage

### Codex

From this checkout, install the local marketplace and plugin:

```bash
codex plugin marketplace add .
codex plugin add blend@blend
```

Once this version is published, replace `.` with `sstoehrm/blend` to install
from GitHub. Start a new session after installation. Review and trust the
plugin's SessionStart hook when Codex prompts; it loads `use-blend` on
startup, resume, clear, and compaction. If hooks are disabled or not trusted,
select `use-blend` in the skill picker or ask: "Load Blend's use-blend skill
and follow it for this task."

To use an individual skill, ask for **Blend's brainstorming skill** or
**Blend's deduce skill**. Select the Blend entry if another plugin exposes
the same name. The skill files are shared by both hosts. Following
[Superpowers' platform adaptation pattern](https://github.com/obra/superpowers/blob/main/skills/using-superpowers/SKILL.md),
`use-blend` conditionally loads a Codex reference for tool mappings;
other hosts don't load that reference.

For GitHub installations, refresh the marketplace before re-adding the
plugin. Local marketplaces read directly from the checkout:

```bash
codex plugin marketplace upgrade blend  # GitHub installations only
codex plugin add blend@blend
```

Start a new session after updates. Keep versions in both plugin manifests
in sync when releasing changes.

Codex packaging and hook behavior follow the official
[plugin documentation](https://developers.openai.com/codex/plugins/build)
and [hook documentation](https://learn.chatgpt.com/docs/hooks).

### Claude Code

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
them first — and bumping the version in both plugin manifests,
since the installed plugin only re-fetches on a version change:

```bash
git push                                # publish the edits (version bumped)
claude plugin marketplace update blend  # refresh the catalog
claude plugin update blend@blend        # re-fetch the installed plugin
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

Instructions shared by Claude Code and Codex. Keep host-specific tool
mappings in a reference loaded conditionally from use-blend.
```

Follow superpowers:writing-skills: test the skill with fresh-context
subagents before deploying. Validate before committing:

```bash
claude plugin validate .
```

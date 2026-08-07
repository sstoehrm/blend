# blend

Personal Claude Code skills, packaged as a plugin marketplace.

## Structure

```
.claude-plugin/marketplace.json     # marketplace catalog
plugins/skills/                     # the "skills" plugin
├── .claude-plugin/plugin.json
└── skills/
    └── <skill-name>/SKILL.md       # one directory per skill
```

## Usage

Add the marketplace (from a local checkout or a git remote):

```bash
claude plugin marketplace add ~/repos/private/blend
# or from GitHub:
claude plugin marketplace add sstoehrm/blend
```

Install the skills plugin:

```bash
claude plugin install skills@soeren-skills --scope user
```

Or in a Claude Code session:

```
/plugin marketplace add ~/repos/private/blend
/plugin install skills@soeren-skills
```

After editing skills, pick up changes with:

```bash
claude plugin marketplace update soeren-skills
```

## Adding a skill

Create `plugins/skills/skills/<skill-name>/SKILL.md`:

```markdown
---
name: skill-name
description: What this skill does and when to use it.
---

Instructions for Claude.
```

Validate before committing:

```bash
claude plugin validate .
```

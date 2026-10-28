# blend

A Claude Code, Codex and Grok Build plugin: working habits loaded into
every session by a session-start hook, plus an opt-in project-setup
checklist. No other workflow plugin is needed. Packaged as a plugin
marketplace.

The review prompt and the TDD/debugging rules are adapted from
[superpowers](https://github.com/obra/superpowers) (MIT); see
`plugins/blend/THIRD_PARTY_NOTICES.md`.

## Skills

| Skill               | What it does |
| ------------------- | ------------ |
| use-blend           | Injected into every session via SessionStart hook: communication style, verification, TDD, debugging and review rules. Offers project-setup when a request fits; it runs only when you say yes or name it. |
| blend:project-setup | A checklist run against the current repo: vulnerability gate in CI (SBOM, OSV-Scanner, KEV/EPSS policy), Dependabot or Renovate, required checks, secret scanning, SAST, workflow hygiene, code and data licenses, third-party notices, privacy, SECURITY.md and repo basics. Reports present/missing first, then adds only what you pick. Use it on every new project. |

## Code review

Blend reviews with its own reviewer prompt
(`plugins/blend/skills/use-blend/reviewer-prompt.md`). One read-only
reviewer checks the change against its requirements, including
correctness, relevant security issues, and unnecessary complexity.
Built-in review, simplify, and security-review commands aren't chained
automatically.

## Structure

```
.claude-plugin/marketplace.json     # Claude Code marketplace catalog
.agents/plugins/marketplace.json   # Codex marketplace catalog
.github/workflows/ci.yml            # CI: the two test scripts and shellcheck
.github/dependabot.yml              # weekly GitHub Actions updates
LICENSE                             # MIT
SECURITY.md                         # how to report a vulnerability
.gitignore                          # local settings
plugins/blend/                      # the "blend" plugin
├── .claude-plugin/plugin.json
├── .codex-plugin/plugin.json
├── hooks/hooks.json                # SessionStart: injects use-blend
├── hooks/install-grok-rules.sh     # Grok only: writes use-blend to ~/.grok/rules/blend.md
├── THIRD_PARTY_NOTICES.md          # MIT notice for text adapted from superpowers
└── skills/
    └── {use-blend,project-setup}/SKILL.md
tests/install-grok-rules.test.sh    # run: sh tests/install-grok-rules.test.sh
tests/check-skills.sh               # line budgets, no stale references
```

## Usage

### Codex

From this checkout, install the local marketplace and plugin:

```bash
codex plugin marketplace add .
codex plugin add blend@blend
```

To install from GitHub instead, replace `.` with `sstoehrm/blend` in the
marketplace command. Start a new session after installation. Review and
trust the plugin's SessionStart hook when Codex prompts; it loads `use-blend` on
startup, resume, clear, and compaction. If hooks are disabled or not trusted,
select `use-blend` in the skill picker or ask: "Load Blend's use-blend skill
and follow it for this task."

To use project-setup, ask for **Blend's project-setup skill**. Select the Blend entry if another plugin
exposes the same name. The skill files are shared by both hosts. `use-blend` conditionally loads a Codex reference for tool mappings;
other hosts don't load that reference.

#### Updating

First check which source Codex uses for Blend:

```bash
codex plugin marketplace list --json
```

Find the `blend` entry and check `marketplaceSource.sourceType`: `local`
means a checkout on disk; `git` means a Git-backed marketplace managed by
Codex. Both install a **cached copy** of the plugin. Editing or pulling
the source alone does not refresh that installed copy.

**Local checkout** (`codex plugin marketplace add .`): update the checkout
shown in `marketplaceSource.source`, then reinstall from it. For the latest
merged changes, run in that checkout:

```bash
git switch main
git pull --ff-only
codex plugin add blend@blend
```

During local development, keep your working branch and run only the last
command to install its current files. `marketplace upgrade` does not pull
or update a local checkout.

**Git-backed marketplace** (`codex plugin marketplace add sstoehrm/blend`):
refresh Codex's marketplace snapshot, then reinstall the plugin:

```bash
codex plugin marketplace upgrade blend
codex plugin add blend@blend
```

If the marketplace was installed with a pinned ref, the refresh follows
that ref; it does not switch to `main`.

Check the installed version, then start a **new Codex thread/session**:

```bash
codex plugin list --marketplace blend
```

An existing conversation keeps its previously loaded skill instructions.
If the hook definition changed, review and trust it again when prompted.
Keep versions in both plugin manifests in sync when releasing changes.

These commands were checked against Codex CLI `0.153.4`. Its
[installer](https://github.com/openai/codex/blob/rust-v0.153.4/codex-rs/core-plugins/src/store.rs)
replaces the cached plugin on `plugin add`, including when the version is
unchanged.

Codex packaging and hook behavior follow the official
[plugin documentation](https://developers.openai.com/codex/plugins/build)
and [hook documentation](https://learn.chatgpt.com/docs/hooks).

### Grok Build

Grok Build reads blend's Claude Code manifest as is. Install it from
GitHub:

```bash
grok plugin install sstoehrm/blend#plugins/blend --trust
```

Or add the repo as a marketplace (`grok plugin marketplace add
sstoehrm/blend`) and install blend from `/plugins`. Update with
`grok plugin update blend`. If blend is installed in Claude Code, Grok
also picks that copy up.

Grok ignores SessionStart hook output, so use-blend can't be injected the
way Claude Code does it. Instead, blend's session hooks write use-blend
plus the Grok reference (`skills/use-blend/references/grok-tools.md`) to
`~/.grok/rules/blend.md`, which Grok loads in every session. The file is
written when the first session starts (interactive) or ends (headless),
so use-blend applies from the next session on. Uninstalling blend leaves
the file; delete it by hand. Grok hides the subagent `model` argument
when only xAI models are available, so the reviewer runs on the session's
model unless you pin types under `[subagents.models]` in
`~/.grok/config.toml`.

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

Add it to the line budgets and skill set in `tests/check-skills.sh`.
Validate before committing:

```bash
sh tests/check-skills.sh
claude plugin validate .
```

## License

MIT (`LICENSE`) for the whole repo, skill text included.
The text adapted from superpowers stays under its MIT notice in
`plugins/blend/THIRD_PARTY_NOTICES.md`.

blend collects no data. Its hooks only write `~/.grok/rules/blend.md`
(under Grok).

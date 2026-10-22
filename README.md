# blend

A Claude Code, Codex and Grok Build plugin: a standalone set of opt-in workflow skills.
[simpleviz](https://github.com/sstoehrm/simpleviz) makes designs visible, and
a session-start hook wires it all together; no other workflow plugin is
needed. Packaged as a plugin marketplace.

Parts of build, review and the TDD/debugging rules are adapted from
[superpowers](https://github.com/obra/superpowers) (MIT); see
`plugins/blend/THIRD_PARTY_NOTICES.md`.

## Skills

| Skill               | What it does |
| ------------------- | ------------ |
| use-blend           | Injected into every session via SessionStart hook: communication style, verification, TDD, debugging and review rules, dependency checks. Offers the other skills when a request fits; they run only when you say yes or name them. The hook also installs blend's simpleviz templates. |
| blend:brainstorming | A free conversation about an idea. Whatever settles is written into `.blend/` right away: a section per feature in `features.md`, plus planned nodes (`:state :new`) in the architecture and module graphs. No levels, gates or fixed steps. |
| blend:build         | Implements what changed in `.blend/` since the last build (`git diff <last "blend: built" commit>` of `features.md` and the graphs is the spec), in one full-auto run: a branch, a local plan in `.blend/plan.md` — served by simpleviz, linking the changed features and graphs, plus a task graph when the order isn't a straight line (gitignored), TDD per task (subagents get a named model tier: cheapest / mid / strong / strongest), one whole-branch review, blend:persist when the structure changed, its features marked built, then an empty `blend: built <slug>` commit as the next base. Keeps the branch; never merges or pushes unasked. |
| blend:persist       | Brings code into the spec — `modules.edn` derived from imports and merged (planned modules survive), `architecture.edn` updated where code changed, built features added to `features.md` and planned ones flipped to built, `intro.md` written and kept current. Source is the range since its last commit, or the current session. Migrates the old `.blend/views/` and `.blend/features/` layouts. |
| blend:project-setup | A checklist run against the current repo: vulnerability gate in CI (SBOM, OSV-Scanner, KEV/EPSS policy), Dependabot or Renovate, required checks, secret scanning, SAST, workflow hygiene, code and data licenses, third-party notices, privacy, SECURITY.md and repo basics. Reports present/missing first, then adds only what you pick. Use it on every new project. |

## The workflow

```
idea ⇄ blend:brainstorming ⇄ .blend/{intro.md, features.md, architecture.edn, modules.edn}
                                         │
                                   blend:build → spec diff → local plan → branch, tests, review → blend:persist (if structure changed)
```

`.blend/` is the project's continuous spec — the only thing blend keeps.
Brainstorm as long and as often as you like; each session starts from
what is in it. `intro.md` says what the project is and links the rest;
serve it and each graph opens beside the text. Features are sections of
`features.md`, planned or built, in free markdown — intent, behaviour,
examples, open questions, whatever fits. The graphs show the structure,
with not-yet-built parts marked and linked to `features.md`. When you want
the code to catch up, blend:build takes the spec's diff since the last
build, plans it in a local file and implements it without asking.

Artifacts in the target project:

```
.blend/
├── intro.md                    # what the project is; links the rest (serve this)
├── features.md                 # every feature, a ## section each, planned or built
├── architecture.edn            # components and flows
├── modules.edn                 # modules and imports, derived from code
└── plan.md (+ plan.edn)        # current build's plan; gitignored, deleted when done
```

Templates: `simpleviz init <file> -t blend-architecture | blend-modules | blend-plan`.

## Code review

Blend reviews with its own reviewer prompt
(`plugins/blend/skills/build/reviewer-prompt.md`). One read-only
reviewer checks the change against its requirements, including
correctness, relevant security issues, and unnecessary complexity.
Built-in review, simplify, and security-review commands aren't chained
automatically.

## Dependencies

| Dependency         | Claude Code install                                                                       |
| ------------------ | ----------------------------------------------------------------------------------------- |
| simpleviz plugin   | `/plugin install simpleviz@simpleviz`                                                     |
| simpleviz launcher (≥ 0.34.0) | `curl -fsSL https://raw.githubusercontent.com/sstoehrm/simpleviz/main/install.sh \| bash` |
| babashka           | https://github.com/babashka/babashka#installation                                         |

use-blend checks these lazily and tells you the fix when one is missing.

In Codex, install the
**simpleviz skill** using Codex's skill installer: provide
`https://github.com/sstoehrm/simpleviz` and select the directory containing
its `SKILL.md`. The simpleviz launcher and babashka are required in both
hosts. A Claude Code plugin installation alone doesn't make its skills
available to Codex. Grok Build picks up Claude Code plugins, simpleviz
included.

## Structure

```
.claude-plugin/marketplace.json     # Claude Code marketplace catalog
.agents/plugins/marketplace.json   # Codex marketplace catalog
.github/workflows/ci.yml            # CI: the three test scripts and shellcheck
.github/dependabot.yml              # weekly GitHub Actions updates
LICENSE                             # MIT
SECURITY.md                         # how to report a vulnerability
.gitignore                          # local settings, blend build plan
plugins/blend/                      # the "blend" plugin
├── .claude-plugin/plugin.json
├── .codex-plugin/plugin.json
├── hooks/hooks.json                # SessionStart: injects use-blend, installs templates
├── hooks/install-templates.sh      # copies templates/ into ~/.simpleviz/templates
├── hooks/install-grok-rules.sh     # Grok only: writes use-blend to ~/.grok/rules/blend.md
├── templates/blend-*.edn           # simpleviz templates (init -t blend-plan …)
├── THIRD_PARTY_NOTICES.md          # MIT notice for text adapted from superpowers
└── skills/
    └── {use-blend,brainstorming,build,persist,project-setup}/SKILL.md
tests/install-templates.test.sh     # run: sh tests/install-templates.test.sh
tests/install-grok-rules.test.sh    # run: sh tests/install-grok-rules.test.sh
tests/check-skills.sh               # line budgets, no stale references
tests/scenarios/                    # headless skill scenarios: tests/scenarios/run.sh
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

To use an individual skill, ask for **Blend's brainstorming skill**,
**Blend's build skill**, **Blend's persist skill** or **Blend's project-setup skill**. Select the Blend entry if another plugin
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
when only xAI models are available, so build's model tiers don't apply
there: subagents run on the session's model unless you pin types under
`[subagents.models]` in `~/.grok/config.toml`.

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

Test the skill with headless scenarios — `tests/scenarios/run.sh` (see
`tests/scenarios/README.md`): a baseline run without the change that
fails, a run with it that passes. Validate before committing:

```bash
claude plugin validate .
```

## License

MIT (`LICENSE`) for the whole repo, skill text and templates included.
The text adapted from superpowers stays under its MIT notice in
`plugins/blend/THIRD_PARTY_NOTICES.md`.

blend collects no data. Its hooks only write `~/.simpleviz/templates`
and `~/.grok/rules/blend.md`.

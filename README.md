# blend

A Claude Code and Codex plugin that blends existing skills into one opinionated
workflow: [superpowers](https://github.com/obra/superpowers) drives the
process, [simpleviz](https://github.com/sstoehrm/simpleviz) makes designs
visible, and a session-start hook wires it all together. Packaged as a
plugin marketplace.

## Skills

| Skill              | What it does                                                                                                                                       |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| use-blend           | Injected into every session via SessionStart hook. Communication style, verification habits, dependency checks, and the phase → skill routing table. The hook also installs blend's simpleviz templates. |
| blend:brainstorming | Wraps superpowers:brainstorming: asks how involved you want to be (high, medium, full auto), refreshes the project views, draws the design as plan views with a plan graph as entry point, and writes `overview.md` instead of a spec. |
| blend:planning      | Replaces superpowers:writing-plans: adds the tasks to the plan graph (dependencies show what can run in parallel), writes one task file per task, and tells execution how to run the plan. |
| blend:project-views | Keeps `.blend/views/architecture.edn` and `.blend/views/modules.edn` current: derives the module graph from code, draws architecture, syncs both after implementation and reports unplanned changes. |
| blend:deduce       | Deduces and maintains a concept graph — a superficial architecture view of a project — from code, plans, or specs. Iterative: user approves concepts, a reviewer subagent validates every element against evidence. Work in progress: not part of the workflow yet, invoke it directly. Writes `.blend/concept.edn` and `.blend/concept-hash` (the commit the graph was validated against; scopes the next update). |

## The workflow

```
idea ──▶ blend:brainstorming ──▶ overview.md + plan views ──▶ blend:planning ──▶ plan graph + task files ──▶ implementation ──▶ sync project views
              │                         ▲                                                                                        │
              ▼                         └──── .blend/views (architecture, modules) ◀─────────────────────────────────────────────┘
      superpowers:brainstorming
```

There is no spec or plan document. Brainstorming refreshes the project
views, then draws what the feature changes as plan views — a slice of the
architecture and of the module graph, marked new / changed / removed /
context — and writes a short `overview.md` (goal, decisions, non-goals,
success criteria). You review those. blend:planning adds the tasks to the
plan graph: edges show order, tasks without a path between them can run
in parallel, and each task links to its task file and to the modules and
components it touches. After implementation the module graph is
re-derived from the code and anything the plan did not predict is
reported.

Brainstorming first asks how involved you want to be:

| Level     | You get asked                                                              |
| --------- | -------------------------------------------------------------------------- |
| High      | Everything superpowers asks: each question, each design section, design review, plan review |
| Medium    | Only design-changing questions; one design review (overview + views), then plan review |
| Full auto | Nothing; the agent decides, implements on a branch, and reports. Never merges or pushes |

Name the level in your request ("full auto", "just decide") to skip the
question.

Artifacts land in the target project:

```
.blend/
├── views/architecture.edn             # project: components and flows, always current
├── views/modules.edn                  # project: every module and its imports, derived from code
├── YYYY-MM-DD-<topic>.edn             # plan graph — the entry point; serve this
└── YYYY-MM-DD-<topic>/
    ├── overview.md                    # goal, decisions, non-goals, success criteria, how to execute
    ├── architecture.edn               # what the plan changes in the architecture
    ├── modules.edn                    # which modules the plan touches, and by which task
    └── tasks/NN-<slug>.md             # one brief per task: files, TDD steps, acceptance
```

Templates: `simpleviz init <file> -t blend-plan | blend-plan-view | blend-architecture | blend-modules`.

## Code review

Blend uses **superpowers:requesting-code-review** for working changes and
PRs, then **superpowers:receiving-code-review** to handle feedback. One
read-only reviewer checks the change against its requirements, including
correctness, relevant security issues, and unnecessary complexity. Review
fixes where needed; reuse an existing review when the diff is unchanged.
Built-in review, simplify, and security-review commands aren't chained
automatically.

| Skill | Fit for Blend |
| --- | --- |
| [Superpowers requesting-code-review](https://github.com/obra/superpowers/blob/main/skills/requesting-code-review/SKILL.md) | Default: general code review with one reviewer, already included in Blend's dependencies. Its [reviewer template](https://github.com/obra/superpowers/blob/main/skills/requesting-code-review/code-reviewer.md) prohibits nested reviewers. |
| [Ponytail review](https://github.com/DietrichGebert/ponytail/blob/main/skills/ponytail-review/SKILL.md) | Useful for a requested over-engineering review. Explicitly excludes correctness, security, and performance, so it cannot replace general code review. Optional; no new dependency. |

## Dependencies

| Dependency         | Claude Code install                                                                       |
| ------------------ | ----------------------------------------------------------------------------------------- |
| superpowers plugin | `/plugin install superpowers@claude-plugins-official`                                     |
| simpleviz plugin   | `/plugin install simpleviz@simpleviz`                                                     |
| simpleviz launcher (≥ 0.32.0) | `curl -fsSL https://raw.githubusercontent.com/sstoehrm/simpleviz/main/install.sh \| bash` |
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
├── hooks/hooks.json                # SessionStart: injects use-blend, installs templates
├── hooks/install-templates.sh      # copies templates/ into ~/.simpleviz/templates
├── templates/blend-*.edn           # simpleviz templates (init -t blend-plan …)
└── skills/
    └── <skill-name>/SKILL.md       # one directory per skill
tests/install-templates.test.sh     # run: sh tests/install-templates.test.sh
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
**Blend's planning skill** or **Blend's project-views skill**. Select the Blend entry if another plugin
exposes the same name. The skill files are shared by both hosts. Following
[Superpowers' platform adaptation pattern](https://github.com/obra/superpowers/blob/main/skills/using-superpowers/SKILL.md),
`use-blend` conditionally loads a Codex reference for tool mappings;
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

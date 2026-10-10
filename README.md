# blend

A Claude Code and Codex plugin: a standalone set of opt-in workflow skills.
[simpleviz](https://github.com/sstoehrm/simpleviz) makes designs visible, and
a session-start hook wires it all together; no other workflow plugin is
needed. Packaged as a plugin marketplace.

Parts of brainstorming, planning, executing and debugging are adapted from
[superpowers](https://github.com/obra/superpowers) (MIT); see
`plugins/blend/THIRD_PARTY_NOTICES.md`.

## Skills

| Skill               | What it does |
| ------------------- | ------------ |
| use-blend           | Injected into every session via SessionStart hook. Always loaded: communication style, verification, TDD and review rules, dependency checks. Offers the other skills when a request fits one; they run only when you say yes or name them. The hook also installs blend's simpleviz templates. |
| blend:brainstorming | Asks how involved you want to be (high, medium, full auto), refreshes the project views, draws the design as plan views with a plan graph as entry point, and writes `overview.md` instead of a spec. |
| blend:planning      | Adds the tasks to the plan graph (dependencies show what can run in parallel), writes one task file per task, and adds plan notes to `overview.md`. |
| blend:executing     | Runs a plan graph task by task, inline or with a subagent per task, tracks `:state` in the graph, reviews with blend's reviewer prompt, and finishes with a whole-branch review and blend:persist. |
| blend:debugging     | Root cause before any fix: reproduce, check what changed, trace, test one hypothesis at a time, then fix with a failing test first. |
| blend:persist       | Keeps `.blend/views/` current — `modules.edn` derived from code, `architecture.edn` drawn and checked, `system.md` written from commits, sessions and plans. Source is a git range, the current session, or a finished plan. |

## The workflow

```
idea → (offer) → blend:brainstorming → overview.md + plan views → blend:planning → plan graph + task files → blend:executing → blend:persist → .blend/views
```

Everything is opt-in: use-blend offers a skill when a request fits, and
you say yes or name it. blend:persist also runs on request, for a session
or a git range.

There is no spec or plan document. Brainstorming refreshes the project
views, then draws what the feature changes as plan views — a slice of the
architecture and of the module graph, marked new / changed / removed /
context — and writes a short `overview.md` (goal, decisions, non-goals,
success criteria). You review those. blend:planning adds the tasks to the
plan graph: edges show order, tasks without a path between them can run
in parallel, and each task links to its task file and to the modules and
components it touches. After implementation blend:persist re-derives the
module graph from the code and reports anything the plan did not predict.

Brainstorming first asks how involved you want to be:

| Level     | You get asked                                                              |
| --------- | -------------------------------------------------------------------------- |
| High      | Every question, each design step, design review, plan review |
| Medium    | Only design-changing questions; approve the design once in chat, then design review (overview + views), then plan review |
| Full auto | Nothing; the agent decides, implements on a branch, and reports. Never merges or pushes |

Name the level in your request ("full auto", "just decide") to skip the
question.

Artifacts land in the target project:

```
.blend/
├── views/architecture.edn             # project: components and flows, always current
├── views/modules.edn                  # project: every module and its imports, derived from code
├── views/system.md                    # project: purpose, constraints, decisions
├── YYYY-MM-DD-<topic>.edn             # plan graph — the entry point; serve this
└── YYYY-MM-DD-<topic>/
    ├── overview.md                    # goal, decisions, non-goals, success criteria, how to execute
    ├── architecture.edn               # what the plan changes in the architecture
    ├── modules.edn                    # which modules the plan touches, and by which task
    └── tasks/NN-<slug>.md             # one brief per task: files, TDD steps, acceptance
```

Templates: `simpleviz init <file> -t blend-plan | blend-plan-view | blend-architecture | blend-modules`.

## Code review

Blend reviews with its own reviewer prompt
(`plugins/blend/skills/executing/reviewer-prompt.md`). One read-only
reviewer checks the change against its requirements, including
correctness, relevant security issues, and unnecessary complexity.
Review fixes where needed; reuse an existing review when the diff is
unchanged. Built-in review, simplify, and security-review commands aren't
chained automatically.

## Dependencies

| Dependency         | Claude Code install                                                                       |
| ------------------ | ----------------------------------------------------------------------------------------- |
| simpleviz plugin   | `/plugin install simpleviz@simpleviz`                                                     |
| simpleviz launcher (≥ 0.32.0) | `curl -fsSL https://raw.githubusercontent.com/sstoehrm/simpleviz/main/install.sh \| bash` |
| babashka           | https://github.com/babashka/babashka#installation                                         |

use-blend checks these lazily and tells you the fix when one is missing.

In Codex, install the
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
├── THIRD_PARTY_NOTICES.md          # MIT notice for text adapted from superpowers
└── skills/
    └── {use-blend,brainstorming,planning,executing,debugging,persist}/SKILL.md
tests/install-templates.test.sh     # run: sh tests/install-templates.test.sh
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
**Blend's planning skill**, **Blend's executing skill**, **Blend's debugging skill** or **Blend's persist skill**. Select the Blend entry if another plugin
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

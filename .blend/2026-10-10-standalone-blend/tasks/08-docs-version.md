# Task 8: Notices, deduce removal, README, version 0.7.0

**Goal:** blend ships without superpowers: license notice in place,
deduce gone, docs and manifests describe the opt-in standalone plugin.

**Files:**
- Create: `plugins/blend/THIRD_PARTY_NOTICES.md`
- Delete: `plugins/blend/skills/deduce/SKILL.md`
- Modify: `README.md`, `plugins/blend/.claude-plugin/plugin.json`,
  `plugins/blend/.codex-plugin/plugin.json`, `.claude-plugin/marketplace.json`

**Interfaces:**
- Consumes: the skill set of tasks 2–7: use-blend, brainstorming,
  planning, executing, debugging, persist.

- [ ] **Step 1: Write the check (it fails now)**

```sh
cat > /tmp/check-standalone.sh <<'EOF'
set -e
cd "$1"
stray=$(grep -rIn -i superpowers plugins/blend | grep -v -e THIRD_PARTY_NOTICES.md -e ':Adapted from superpowers' || true)
[ -z "$stray" ] || { echo "$stray"; exit 1; }
test -f plugins/blend/THIRD_PARTY_NOTICES.md && grep -q "Copyright (c) 2025 Jesse Vincent" plugins/blend/THIRD_PARTY_NOTICES.md
test ! -e plugins/blend/skills/deduce && test ! -e plugins/blend/skills/project-views
for f in plugins/blend/.claude-plugin/plugin.json plugins/blend/.codex-plugin/plugin.json; do
  jq -e '.version == "0.7.0"' $f >/dev/null
  if grep -qi superpowers $f; then echo "$f mentions superpowers"; exit 1; fi; done
if grep -qi superpowers .claude-plugin/marketplace.json; then echo "marketplace mentions superpowers"; exit 1; fi
for s in use-blend:120 brainstorming:150 planning:120 executing:150 debugging:80 persist:120; do
  n=${s%%:*} max=${s##*:}; [ $(wc -l < plugins/blend/skills/$n/SKILL.md) -le $max ] || { echo "$n over budget"; exit 1; }; done
[ $(wc -l < plugins/blend/skills/executing/reviewer-prompt.md) -le 60 ]
for n in deduce project-views; do
  if grep -rq "blend:$n" README.md plugins/blend; then echo "blend:$n still referenced"; exit 1; fi; done
echo PASS
EOF
sh /tmp/check-standalone.sh .
```

Expected now: FAIL (deduce exists, version 0.6.0).

"superpowers" may appear only in THIRD_PARTY_NOTICES.md and on lines
starting "Adapted from superpowers" (a wrapped credit's second line must
not contain the word).

- [ ] **Step 2: Notices and deduce**

```sh
{ printf '# Third-party notices\n\nblend:brainstorming, blend:planning, blend:executing (and its reviewer\nprompt) and blend:debugging adapt text from superpowers\n(https://github.com/obra/superpowers), used under the MIT License:\n\n```\n'
  cat ~/.claude/plugins/cache/claude-plugins-official/superpowers/6.4.1/LICENSE
  printf '```\n'; } > plugins/blend/THIRD_PARTY_NOTICES.md
git rm -q plugins/blend/skills/deduce/SKILL.md
```

- [ ] **Step 3: Manifests**

Both plugin.json: `"version": "0.7.0"`, `"description": "Sören's workflow
skills — opt-in design, planning and execution with simpleviz graphs"`.
Codex plugin.json `interface.longDescription`: `"Opt-in skills for
designing with simpleviz plan graphs, planning tasks, executing them, and
keeping architecture, module and system views current."`
marketplace.json plugin `description`: same as plugin.json's.

- [ ] **Step 4: README**

Rewrite these parts; leave Usage/Codex/Claude Code install mechanics
unchanged except superpowers lines:

- Intro: blend is a standalone set of opt-in skills; simpleviz makes
  designs visible; no other workflow plugin is needed. Credit line:
  "Parts of brainstorming, planning, executing and debugging are adapted
  from [superpowers](https://github.com/obra/superpowers) (MIT); see
  `plugins/blend/THIRD_PARTY_NOTICES.md`."
- `## Skills` table: use-blend (always loaded: style, verification, TDD,
  review rules; offers the others), blend:brainstorming, blend:planning,
  blend:executing, blend:debugging, blend:persist — one row each, what
  it does in one or two sentences. No deduce, no project-views.
- `## The workflow`: diagram `idea → (offer) → blend:brainstorming →
  overview.md + plan views → blend:planning → plan graph + task files →
  blend:executing → blend:persist → .blend/views`; text: everything is
  opt-in; persist also runs on request for a session or a git range.
  Involvement table: High row says "Every question, each design step,
  design review, plan review" (no "superpowers").
- Artifacts tree: add `views/system.md  # project: purpose, constraints, decisions`.
- `## Code review`: blend's reviewer prompt
  (`plugins/blend/skills/executing/reviewer-prompt.md`) with one
  reviewer; drop the superpowers rows and links.
- `## Dependencies`: remove the superpowers row and the Codex superpowers
  install paragraph.
- `## Structure` tree: skills/{use-blend,brainstorming,planning,executing,debugging,persist},
  THIRD_PARTY_NOTICES.md; no deduce or project-views.
- Usage text naming "Blend's project-views skill" → "Blend's persist
  skill"; the sentence linking superpowers' platform adaptation pattern →
  drop the link, keep the instruction.
- `## Adding a skill`: test it with headless scenarios —
  `tests/scenarios/run.sh` (see `tests/scenarios/README.md`): a baseline
  run without the change that fails, a run with it that passes.

- [ ] **Step 5: Verify**

`sh /tmp/check-standalone.sh .` prints `PASS`; `sh tests/install-templates.test.sh`
all ok; `jq . plugins/blend/.codex-plugin/plugin.json >/dev/null`.

- [ ] **Step 6: Commit**

```sh
git add -A plugins/blend README.md .claude-plugin/marketplace.json
git commit -m "feat!: blend 0.7.0 — standalone, opt-in; drop deduce; MIT notice for superpowers text"
```

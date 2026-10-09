# Task 2: use-blend routing and simpleviz version floor

**Goal:** use-blend routes design, planning, finishing and "how does it fit
together" to the new skills, and requires simpleviz ≥ 0.32.0.

**Files:**
- Modify: `plugins/blend/skills/use-blend/SKILL.md` (Dependencies table,
  Workflow → Skill Routing table)
- Modify: `plugins/blend/skills/use-blend/references/codex-tools.md`
  (one line: templates are installed by the hook)

**Interfaces:**
- Consumes: skill names `blend:planning`, `blend:project-views` (tasks 3,
  5; names fixed in Global constraints).
- Produces: routing that tasks 4 and 5 rely on: no route leads to
  superpowers:writing-plans.

- [ ] **Step 1: Write the routing scenarios**

Each scenario is one fresh subagent, given this prompt with `<USE_BLEND>`
replaced by the path of the use-blend SKILL.md under test:

```
You are a coding agent in a Claude Code session. This text was injected at
session start: read <USE_BLEND> and follow it. Do not edit files.
For each user message below, name the skill(s) you would load first, in
order, and quote the line that decides it.
A. "The design is approved — write the implementation plan."
B. "How do the modules in this repo fit together?"
C. "All tasks are done and reviewed, let's finish the branch."
D. "simpleviz --version prints v0.30.1. Start brainstorming a feature."
```

Pass criteria: A → blend:planning, never superpowers:writing-plans;
B → blend:project-views; C → blend:project-views (sync) before
verification-before-completion and finishing-a-development-branch;
D → tells the user to run `simpleviz update` before using templates.

- [ ] **Step 2: Run the baseline to verify it fails**

Run the four scenarios against the current file
(`plugins/blend/skills/use-blend/SKILL.md` at this branch's base).
Expected: A routes to superpowers:writing-plans, B to nothing specific,
C skips the sync, D accepts v0.30.1. Record the answers.

- [ ] **Step 3: Edit the Dependencies table**

Replace the simpleviz launcher row with:

```markdown
| simpleviz launcher | `simpleviz --version` ≥ v0.32.0   | `curl -fsSL https://raw.githubusercontent.com/sstoehrm/simpleviz/main/install.sh \| bash`; older: `simpleviz update` |
```

Add below the table:

```markdown
blend's simpleviz templates (`blend-plan`, `blend-architecture`,
`blend-modules`, `blend-plan-view`) are installed by blend's SessionStart
hook once simpleviz is installed; after installing simpleviz mid-session,
start a new session or run `/clear` to get them.
```

- [ ] **Step 4: Edit the routing table**

Replace the rows New feature / idea, Spec, Implementation plan,
Implementation and Finishing, and add one row, so the table reads:

```markdown
| Phase                   | Route through                                                                                                                         | Loop until                               |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------- |
| New feature / idea      | blend:brainstorming (loads superpowers:brainstorming; design as plan views + overview.md)                                             | design agreed (or full auto chosen)      |
| Writing/editing a skill | superpowers:writing-skills                                                                                                            | subagent tests pass                      |
| Design + mock-ups       | blend:brainstorming, then artifact-design / dataviz for the mock-up                                                                   | reviewer satisfied                       |
| Design review           | blend:brainstorming (overview.md + plan views; no spec document)                                                                      | reviewer satisfied                       |
| Implementation plan     | plan mode + blend:planning — never superpowers:writing-plans                                                                          | reviewer satisfied                       |
| Implementation          | superpowers:executing-plans or subagent-driven-development, following the plan's overview.md "Executing this plan", with test-driven-development | tests green, per-task review clean       |
| Bug / failing test      | superpowers:systematic-debugging                                                                                                      | root cause found, regression test passes |
| Code review             | superpowers:requesting-code-review; superpowers:receiving-code-review for feedback                                                    | no blocking findings                     |
| Finishing               | blend:project-views (sync after implementation), then superpowers:verification-before-completion, then finishing-a-development-branch | evidence shown, not asserted             |
| How the system fits together | blend:project-views                                                                                                              | views match the code                     |
```

- [ ] **Step 5: Edit the Codex reference**

In `references/codex-tools.md`, after "The simpleviz launcher and
babashka checks in `use-blend` apply unchanged." add:

```markdown
blend's simpleviz templates are installed by the SessionStart hook; if
hooks are disabled, copy `../../../templates/blend-*.edn` (relative to
this reference's directory) to `~/.simpleviz/templates/`.
```

- [ ] **Step 6: Run the scenarios to verify they pass**

Run the four scenarios against the edited file.
Expected: all four pass criteria from Step 1 met. A failure means the
wording isn't binding — tighten the row, re-run.

- [ ] **Step 7: Commit**

```bash
git add plugins/blend/skills/use-blend
git commit -m "feat(use-blend): route design, planning and finishing to graph-native skills"
```

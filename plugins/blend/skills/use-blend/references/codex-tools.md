# Blend in Codex

Read this reference only in Codex. The shared skills keep their workflow
and tool names; apply the mappings below when following them.

## Skills and Dependencies

Load skills by reading the `SKILL.md` path in the installed skill list.
Resolve names such as `blend:brainstorming` by plugin and skill, not by
skill name alone. Blend's sibling skills
are at `../../<skill-name>/SKILL.md` relative to this reference's directory.

For missing dependencies, use Codex's installers rather than the Claude
Code `/plugin install` commands in the shared skill:

- **simpleviz:** use the skill installer with
  [the simpleviz repository](https://github.com/sstoehrm/simpleviz) and the
  directory containing its `SKILL.md`.

The simpleviz launcher and babashka checks in `use-blend` apply unchanged.

blend's simpleviz templates are installed by the SessionStart hook; if
hooks are disabled, copy `../../../templates/blend-*.edn` (relative to
this reference's directory) to `${SIMPLEVIZ_HOME:-~/.simpleviz}/templates/`.

## Tool Mapping

- **Reviewer subagent:** use an available subagent tool. Without one,
  review in a separate pass and say the review wasn't independent.

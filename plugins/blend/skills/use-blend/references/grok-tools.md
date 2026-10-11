# Blend in Grok

Read this only in Grok Build. The shared skills keep their workflow and
tool names; apply these mappings when following them.

## Loading

- Grok ignores SessionStart hook output, so blend's hook copies use-blend
  and this reference to `~/.grok/rules/blend.md`, which Grok loads in
  every session. It takes effect from the session after the first run.
- `blend:<skill>` is the `<skill>` skill of the blend plugin. Another
  plugin's skill with the same name (another brainstorming, say)
  is not it; use the qualified `blend:<skill>` form.
- simpleviz: Grok picks up the Claude Code plugin; otherwise
  `grok plugin marketplace add sstoehrm/simpleviz` and install it from
  `/plugins`. The launcher and babashka checks in use-blend apply as is.

## Tools

- **Subagents:** `spawn_subagent` (`prompt`, `description`, `model`).
  Only the top-level session spawns; a subagent can't spawn its own.
- **Model tiers:** pass `model` per blend:build's table — cheapest
  `grok-4.5`, mid `grok-4.6`, strong `grok-4.7`, strongest `grok-4.7`
  (no stronger Grok model). If `spawn_subagent` has no `model` argument
  (subagent model inheritance is on), subagents inherit the session's
  model; say so in the report.
- **Web:** `web_fetch` is off unless `GROK_WEB_FETCH=1`; use `web_search`
  for current docs when it is.

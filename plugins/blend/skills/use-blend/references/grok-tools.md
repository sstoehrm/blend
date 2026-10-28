# Blend in Grok

Read this only in Grok Build. The shared skills keep their workflow and
tool names; apply these mappings when following them.

## Loading

- Grok ignores SessionStart hook output, so blend's hook copies use-blend
  and this reference to `~/.grok/rules/blend.md`, which Grok loads in
  every session. It takes effect from the session after the first run.
- `blend:<skill>` is the `<skill>` skill of the blend plugin. Another
  plugin's skill with the same name (another project-setup, say)
  is not it; use the qualified `blend:<skill>` form.

## Tools

- **Subagents:** `spawn_subagent` (`prompt`, `description`, `background`).
  Only the top-level session spawns; a subagent can't spawn its own.
- **Models:** Grok hides `spawn_subagent`'s `model` argument when
  every available model is an xAI model, so subagents run on the
  session's model. Pass `model` only if the argument exists; otherwise
  say in the report that the reviewer inherited the session model.
  Per-type pins live in `~/.grok/config.toml` under `[subagents.models]`
  (the user's choice).
- **Web:** `web_fetch` is off unless `GROK_WEB_FETCH=1`; use `web_search`
  for current docs when it is.

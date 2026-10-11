# Due dates

Todos can carry a due date so overdue ones stand out.

- `python3 todo.py add <text...> --due YYYY-MM-DD` stores the date with the todo;
  `--due` is optional and may appear anywhere after `add`.
- `list` shows `(due YYYY-MM-DD)` after the text, and `OVERDUE` when the date
  is before today and the todo is not done.
- A malformed date exits non-zero with an error and stores nothing.
- Todos without a due date list as before.

Touches: architecture#todo-cli, modules#todo

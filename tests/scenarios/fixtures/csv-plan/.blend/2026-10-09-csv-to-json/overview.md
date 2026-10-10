# CSV to JSON CLI

## Goal
A Python command-line tool, `csv2json`, that converts CSV to JSON.

## Assumptions (full auto, no questions asked)
- Single user, general-purpose tool; Python 3.9+, standard library only.
- Input is a CSV with a header row; output is a JSON array of objects, one per row, keyed by header.

## Decisions
- Invocation: `csv2json [INPUT] [-o OUTPUT] [--indent N] [--delimiter C]`; INPUT and OUTPUT default to stdin and stdout; `-` also means stdin.
- All values stay strings (no type guessing), so no data is silently altered.
- Layout: `src/csv2json/` with `convert.py` (pure, no I/O), `cli.py` (argparse, I/O, exit codes), `__main__.py`; tests under `tests/` with pytest. Entry point via `pyproject.toml`.
- Approach chosen: stdlib `csv.DictReader` + `json`. Rejected: pandas (heavy dependency), type inference (surprising output).

## Behavior
- Output is written as UTF-8; the default indent is 2, `--indent 0` gives compact output.
- Empty input (no header) yields `[]`. Header only yields `[]`.
- A row with more or fewer fields than the header is an error: exit 1, stderr names the line number.
- Duplicate header names are an error (exit 1).
- Unreadable input file: message on stderr, exit 2.

## Non-goals
JSON to CSV, type inference, streaming huge files, JSON Lines output, packaging to PyPI.

## Success criteria
`csv2json data.csv` and `cat data.csv | csv2json` print the expected array; error cases above exit non-zero with a clear stderr message.

## Testing
pytest: unit tests for `convert` (basic, quoted commas and newlines, empty, ragged row, duplicate header, custom delimiter); CLI tests via `main(argv)` with `capsys`/`tmp_path` for file, stdin, `-o`, exit codes.

## Open points
None.

## Plan
Tech stack: Python 3.9+, standard library (`csv`, `json`, `argparse`), setuptools build backend, pytest for tests. Three tasks in a chain: converter (with project scaffold), CLI, entry points.

## Global constraints
- Python 3.9+ compatible syntax (no `X | Y` annotations, no `match`); standard library only at runtime, pytest only for tests.
- Layout `src/csv2json/` (`convert.py`, `cli.py`, `__main__.py`), tests in `tests/`.
- `convert.py` does no I/O; only `cli.py` touches files, stdin, stdout and stderr.
- Exit codes: 0 ok, 1 data error (ragged row, duplicate header), 2 unreadable input, unwritable output or usage error.
- All values stay strings; output is UTF-8, default indent 2, `--indent 0` compact.

## Review focus
- Input with a UTF-8 BOM (common from Excel): the first header name must not carry the BOM. Test in task 2.
- CRLF line endings and a trailing blank line: no ragged-row error, no empty object. Test in task 1.
- Non-ASCII text (e.g. `Jürgen`): written as UTF-8, not `\u` escapes. Test in task 2.
- Input that is not valid UTF-8: exit 2 with a clear stderr message, no traceback. Test in task 2.
- Multiline quoted field followed by a ragged row: the reported line number is the last line of that record. Test in task 1.

## Executing this plan

Plan graph: `.blend/2026-10-09-csv-to-json.edn`. Use superpowers:subagent-driven-development
or superpowers:executing-plans. Task order follows the graph's edges;
tasks without a path between them are independent. Each task's brief is
its task file plus this overview and the views its node links to. Set the
task node's `:state` as you go: `:in-progress` when started, `:done` once
its review is clean, `:blocked` with `:reason "<why>"`. After the last
task, load blend:project-views and run its "Sync after implementation"
against this plan.

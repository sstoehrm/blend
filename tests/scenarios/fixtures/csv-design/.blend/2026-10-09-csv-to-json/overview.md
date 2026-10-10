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
None. Plan graph has no task nodes yet; blend:planning adds them.

# Task 2: Command-line front end

**Files:**
- Create: `src/csv2json/cli.py`
- Test: `tests/test_cli.py`

**Interfaces:**
- Consumes: `convert(text: str, delimiter: str = ",") -> list[dict[str, str]]`
  and `ConvertError` (with `.line`) from `csv2json.convert` (Task 1).
- Produces: `main(argv: Optional[Sequence[str]] = None) -> int` returning the
  exit code (0 ok, 1 data error, 2 I/O or usage error). It does not call
  `sys.exit`; `__main__` and the console script do (Task 3).

- [ ] **Step 1: Write the failing tests**

`tests/test_cli.py`:

```python
import io
import json

from csv2json.cli import main


def set_stdin(monkeypatch, data: bytes):
    monkeypatch.setattr("sys.stdin", io.TextIOWrapper(io.BytesIO(data), encoding="utf-8"))


def test_file_to_stdout(tmp_path, capsys):
    src = tmp_path / "d.csv"
    src.write_text("a,b\n1,2\n", encoding="utf-8")
    assert main([str(src)]) == 0
    assert json.loads(capsys.readouterr().out) == [{"a": "1", "b": "2"}]


def test_default_indent_is_2(tmp_path, capsys):
    src = tmp_path / "d.csv"
    src.write_text("a\n1\n", encoding="utf-8")
    main([str(src)])
    assert capsys.readouterr().out == '[\n  {\n    "a": "1"\n  }\n]\n'


def test_indent_zero_is_compact(tmp_path, capsys):
    src = tmp_path / "d.csv"
    src.write_text("a,b\n1,2\n", encoding="utf-8")
    main([str(src), "--indent", "0"])
    assert capsys.readouterr().out == '[{"a":"1","b":"2"}]\n'


def test_stdin_default_and_dash(monkeypatch, capsys):
    set_stdin(monkeypatch, b"a\n1\n")
    assert main([]) == 0
    assert json.loads(capsys.readouterr().out) == [{"a": "1"}]
    set_stdin(monkeypatch, b"a\n2\n")
    assert main(["-"]) == 0
    assert json.loads(capsys.readouterr().out) == [{"a": "2"}]


def test_output_file(tmp_path, capsys):
    src = tmp_path / "d.csv"
    out = tmp_path / "o.json"
    src.write_text("a\n1\n", encoding="utf-8")
    assert main([str(src), "-o", str(out)]) == 0
    assert capsys.readouterr().out == ""
    assert json.loads(out.read_text(encoding="utf-8")) == [{"a": "1"}]


def test_delimiter(tmp_path, capsys):
    src = tmp_path / "d.csv"
    src.write_text("a;b\n1;2\n", encoding="utf-8")
    assert main([str(src), "--delimiter", ";"]) == 0
    assert json.loads(capsys.readouterr().out) == [{"a": "1", "b": "2"}]


def test_ragged_row_exit_1_with_line(tmp_path, capsys):
    src = tmp_path / "d.csv"
    src.write_text("a,b\n1,2\n3\n", encoding="utf-8")
    assert main([str(src)]) == 1
    captured = capsys.readouterr()
    assert captured.out == ""
    assert "line 3" in captured.err


def test_duplicate_header_exit_1(tmp_path, capsys):
    src = tmp_path / "d.csv"
    src.write_text("a,a\n1,2\n", encoding="utf-8")
    assert main([str(src)]) == 1
    assert "line 1" in capsys.readouterr().err


def test_missing_input_exit_2(tmp_path, capsys):
    assert main([str(tmp_path / "nope.csv")]) == 2
    assert "nope.csv" in capsys.readouterr().err


def test_invalid_utf8_exit_2(tmp_path, capsys):
    src = tmp_path / "d.csv"
    src.write_bytes(b"a\n\xff\n")
    assert main([str(src)]) == 2
    assert "UTF-8" in capsys.readouterr().err


def test_bom_is_stripped(tmp_path, capsys):
    src = tmp_path / "d.csv"
    src.write_bytes(b"\xef\xbb\xbfa\n1\n")
    assert main([str(src)]) == 0
    assert json.loads(capsys.readouterr().out) == [{"a": "1"}]


def test_non_ascii_written_as_utf8(tmp_path):
    src = tmp_path / "d.csv"
    out = tmp_path / "o.json"
    src.write_text("name\nJürgen\n", encoding="utf-8")
    assert main([str(src), "-o", str(out)]) == 0
    assert "Jürgen" in out.read_bytes().decode("utf-8")


def test_multichar_delimiter_is_usage_error(tmp_path, capsys):
    src = tmp_path / "d.csv"
    src.write_text("a\n1\n", encoding="utf-8")
    assert main([str(src), "--delimiter", ";;"]) == 2
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `python -m pytest tests/test_cli.py -v`
Expected: FAIL / ERROR with `ModuleNotFoundError` for `csv2json.cli`.

- [ ] **Step 3: Write the implementation**

`src/csv2json/cli.py`:

```python
"""Command-line front end: argument parsing, I/O, exit codes."""
import argparse
import json
import sys
from typing import Optional, Sequence

from csv2json.convert import ConvertError, convert


def _single_char(value: str) -> str:
    if len(value) != 1:
        raise argparse.ArgumentTypeError("must be a single character")
    return value


def _build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        prog="csv2json", description="Convert CSV (with header row) to a JSON array."
    )
    p.add_argument("input", nargs="?", default="-", help="CSV file, or - for stdin (default)")
    p.add_argument("-o", "--output", help="JSON file to write (default: stdout)")
    p.add_argument("--indent", type=int, default=2, help="indent width; 0 = compact (default 2)")
    p.add_argument("--delimiter", type=_single_char, default=",", help="field delimiter (default ,)")
    return p


def _read(path: str) -> str:
    if path == "-":
        raw = sys.stdin.buffer.read()
    else:
        with open(path, "rb") as f:
            raw = f.read()
    return raw.decode("utf-8-sig")


def _dump(rows: list, indent: int) -> str:
    if indent <= 0:
        text = json.dumps(rows, ensure_ascii=False, separators=(",", ":"))
    else:
        text = json.dumps(rows, ensure_ascii=False, indent=indent)
    return text + "\n"


def main(argv: Optional[Sequence[str]] = None) -> int:
    try:
        args = _build_parser().parse_args(argv)
    except SystemExit as e:  # argparse exits on usage errors and --help
        return e.code if isinstance(e.code, int) else 2

    try:
        text = _read(args.input)
    except UnicodeDecodeError:
        print(f"csv2json: {args.input}: input is not valid UTF-8", file=sys.stderr)
        return 2
    except OSError as e:
        print(f"csv2json: cannot read {args.input}: {e.strerror or e}", file=sys.stderr)
        return 2

    try:
        rows = convert(text, args.delimiter)
    except ConvertError as e:
        print(f"csv2json: line {e.line}: {e}", file=sys.stderr)
        return 1

    out = _dump(rows, args.indent)
    if args.output:
        try:
            with open(args.output, "w", encoding="utf-8", newline="") as f:
                f.write(out)
        except OSError as e:
            print(f"csv2json: cannot write {args.output}: {e.strerror or e}", file=sys.stderr)
            return 2
    else:
        if hasattr(sys.stdout, "reconfigure"):
            sys.stdout.reconfigure(encoding="utf-8")
        sys.stdout.write(out)
    return 0
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `python -m pytest tests -v`
Expected: all tests in `test_convert.py` and `test_cli.py` pass (22 passed).

- [ ] **Step 5: Commit**

```bash
git add src/csv2json/cli.py tests/test_cli.py
git commit -m "feat: add csv2json command-line front end"
```

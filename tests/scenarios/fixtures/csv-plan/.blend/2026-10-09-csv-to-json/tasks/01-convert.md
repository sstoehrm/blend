# Task 1: Project scaffold and converter

**Files:**
- Create: `pyproject.toml`
- Create: `src/csv2json/__init__.py` (empty)
- Create: `src/csv2json/convert.py`
- Test: `tests/test_convert.py`

**Interfaces:**
- Consumes: nothing.
- Produces: `class ConvertError(ValueError)` with attribute `line: int`;
  `convert(text: str, delimiter: str = ",") -> list[dict[str, str]]`.
  `ConvertError.args[0]` is the message without the line prefix.

- [ ] **Step 1: Write the scaffold and the failing tests**

`pyproject.toml`:

```toml
[build-system]
requires = ["setuptools>=61"]
build-backend = "setuptools.build_meta"

[project]
name = "csv2json"
version = "0.1.0"
requires-python = ">=3.9"

[tool.setuptools.packages.find]
where = ["src"]

[tool.pytest.ini_options]
pythonpath = ["src"]
testpaths = ["tests"]
```

`tests/test_convert.py`:

```python
import pytest

from csv2json.convert import ConvertError, convert


def test_basic():
    assert convert("a,b\n1,2\n3,4\n") == [
        {"a": "1", "b": "2"},
        {"a": "3", "b": "4"},
    ]


def test_values_stay_strings():
    assert convert("n\n007\n") == [{"n": "007"}]


def test_quoted_comma_and_newline():
    text = 'a,b\n"x,y","line1\nline2"\n'
    assert convert(text) == [{"a": "x,y", "b": "line1\nline2"}]


def test_empty_input_and_header_only():
    assert convert("") == []
    assert convert("a,b\n") == []


def test_crlf_and_trailing_blank_line():
    assert convert("a,b\r\n1,2\r\n\r\n") == [{"a": "1", "b": "2"}]


def test_custom_delimiter():
    assert convert("a;b\n1;2\n", delimiter=";") == [{"a": "1", "b": "2"}]


def test_ragged_row_names_line():
    with pytest.raises(ConvertError) as err:
        convert("a,b\n1,2\n3\n")
    assert err.value.line == 3


def test_ragged_row_after_multiline_field_names_last_line():
    with pytest.raises(ConvertError) as err:
        convert('a,b\n"x\ny",1,extra\n')
    assert err.value.line == 3


def test_duplicate_header():
    with pytest.raises(ConvertError) as err:
        convert("a,a\n1,2\n")
    assert err.value.line == 1
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `python -m pytest tests/test_convert.py -v`
Expected: FAIL / ERROR with `ModuleNotFoundError: No module named 'csv2json'`
(or `convert`).

- [ ] **Step 3: Write the implementation**

Create an empty `src/csv2json/__init__.py`, then `src/csv2json/convert.py`:

```python
"""Pure CSV text -> list of dicts conversion. No I/O."""
import csv
import io


class ConvertError(ValueError):
    def __init__(self, message: str, line: int):
        super().__init__(message)
        self.line = line


def convert(text: str, delimiter: str = ",") -> list:
    reader = csv.reader(io.StringIO(text, newline=""), delimiter=delimiter)
    header = None
    rows = []
    for fields in reader:
        if not fields:  # blank line
            continue
        if header is None:
            if len(set(fields)) != len(fields):
                raise ConvertError("duplicate header names", reader.line_num)
            header = fields
            continue
        if len(fields) != len(header):
            raise ConvertError(
                f"expected {len(header)} fields, got {len(fields)}",
                reader.line_num,
            )
        rows.append(dict(zip(header, fields)))
    return rows
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `python -m pytest tests/test_convert.py -v`
Expected: 9 passed

- [ ] **Step 5: Commit**

```bash
git add pyproject.toml src/csv2json tests/test_convert.py
git commit -m "feat: add csv2json converter"
```

# Task 3: Entry points

**Files:**
- Create: `src/csv2json/__main__.py`
- Modify: `pyproject.toml` (add `[project.scripts]`)
- Test: `tests/test_main.py`

**Interfaces:**
- Consumes: `main(argv=None) -> int` from `csv2json.cli` (Task 2).
- Produces: `python -m csv2json ...` and the `csv2json` console script; both
  exit with `main()`'s return value.

- [ ] **Step 1: Write the failing test**

`tests/test_main.py`:

```python
import json
import os
import subprocess
import sys

SRC = os.path.join(os.path.dirname(__file__), "..", "src")


def run(args, stdin=b""):
    env = dict(os.environ, PYTHONPATH=SRC)
    return subprocess.run(
        [sys.executable, "-m", "csv2json", *args],
        input=stdin, capture_output=True, env=env,
    )


def test_module_pipes_stdin_to_stdout():
    r = run([], b"a,b\n1,2\n")
    assert r.returncode == 0
    assert json.loads(r.stdout) == [{"a": "1", "b": "2"}]


def test_module_propagates_exit_code():
    r = run([], b"a,b\n1\n")
    assert r.returncode == 1
    assert b"line 2" in r.stderr
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `python -m pytest tests/test_main.py -v`
Expected: FAIL (`No module named csv2json.__main__`, nonzero return code).

- [ ] **Step 3: Write the implementation**

`src/csv2json/__main__.py`:

```python
import sys

from csv2json.cli import main

sys.exit(main())
```

Append to `pyproject.toml`:

```toml
[project.scripts]
csv2json = "csv2json.cli:main"
```

(`console_scripts` call `sys.exit(main())`, so the int return becomes the exit code.)

- [ ] **Step 4: Run all tests, then smoke-test the scripts**

Run: `python -m pytest tests -v`
Expected: 24 passed

Run: `printf 'a,b\n1,2\n' | python -m csv2json` (with `PYTHONPATH=src`)
Expected:

```
[
  {
    "a": "1",
    "b": "2"
  }
]
```

- [ ] **Step 5: Commit**

```bash
git add src/csv2json/__main__.py pyproject.toml tests/test_main.py
git commit -m "feat: add python -m csv2json and csv2json script"
```

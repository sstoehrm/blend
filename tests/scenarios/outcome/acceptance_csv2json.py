import csv, io, json, os, subprocess, sys, tempfile

repo = sys.argv[1]
cands = [[os.path.join(repo, "csv2json")], [sys.executable, "-m", "csv2json"],
         [sys.executable, os.path.join(repo, "csv2json.py")]]

def usable(c):
    if c[1:2] == ["-m"]:  # module form: needs csv2json.py or a csv2json/ package in repo
        return (os.path.isfile(os.path.join(repo, "csv2json.py"))
                or os.path.isdir(os.path.join(repo, "csv2json")))
    return os.path.isfile(c[-1])

def run(args, stdin=""):
    for c in cands:
        if not usable(c):
            continue
        try:
            p = subprocess.run(c + args, input=stdin, capture_output=True, text=True, cwd=repo)
        except OSError:  # not executable, bad interpreter, vanished: try the next candidate
            continue
        if p.returncode != 127 and "No module named" not in p.stderr:
            return p
    raise SystemExit("FAIL no runnable csv2json")

checks = 0
p = run([], "a,b\n1,2\n3,4\n")
assert json.loads(p.stdout) == [{"a": "1", "b": "2"}, {"a": "3", "b": "4"}], p.stdout; checks += 1
f = tempfile.NamedTemporaryFile("w", suffix=".csv", delete=False); f.write('n,q\nx,"a,b"\n'); f.close()
p = run([f.name])
assert json.loads(p.stdout) == [{"n": "x", "q": "a,b"}], p.stdout; checks += 1
p = run([], "a,b\n")
assert json.loads(p.stdout) == [], p.stdout; checks += 1
p = run(["/nonexistent.csv"])
assert p.returncode != 0 and p.stderr, "missing file must fail with a message"; checks += 1
print(f"PASS {checks}/4")

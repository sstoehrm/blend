import json, sys
from pathlib import Path

DB = Path("todos.json")

def load():
    return json.loads(DB.read_text()) if DB.exists() else []

def main(argv):
    todos = load()
    if argv[:1] == ["add"]:
        todos.append({"text": " ".join(argv[1:]), "done": False})
        DB.write_text(json.dumps(todos))
    elif argv[:1] == ["list"]:
        for i, t in enumerate(todos, 1):
            print(f"{i}. [{'x' if t['done'] else ' '}] {t['text']}")

if __name__ == "__main__":
    main(sys.argv[1:])

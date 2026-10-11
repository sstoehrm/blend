import json, os, tempfile, unittest
import todo

class TodoTest(unittest.TestCase):
    def setUp(self):
        os.chdir(tempfile.mkdtemp())
    def test_add_then_list(self):
        todo.main(["add", "buy", "milk"])
        self.assertEqual(json.loads(open("todos.json").read())[0]["text"], "buy milk")

if __name__ == "__main__":
    unittest.main()

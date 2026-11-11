#!/bin/bash
set -uxo pipefail

source /opt/conda/etc/profile.d/conda.sh
conda activate testbed

cd /testbed
git checkout 5e8bd105177e08848990d32b9ea636daa639be19

# Apply the test patch before testing
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_researcher.py b/tests/test_researcher.py
new file mode 100644
index 0000000..e1a2f3b
--- /dev/null
+++ b/tests/test_researcher.py
@@ -0,0 +1,167 @@
+import pytest
+import asyncio
+from metagpt.roles.researcher import Researcher
+
+@pytest.mark.asyncio
+async def test_researcher_enable_concurrency_flag():
+    # Create Researcher with concurrency enabled
+    researcher = Researcher(enable_concurrency=True)
+    assert researcher.enable_concurrency is True
+
+    # Mock a todo with links to simulate _act concurrency
+    class DummyTodo:
+        name = "DummyTodo"
+        async def run(self, url, query=None, system_text=None):
+            await asyncio.sleep(0.01)
+            return {url: f"summary for {url}"}
+
+    # Setup rc with dummy todo and links
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.__class__ = DummyTodo
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.run = DummyTodo().run
+    # Setup links attribute expected by _act
+    researcher.rc.todo.links = {"http://example.com": "query"}
+
+    # Patch instruct_content to simulate WebBrowseAndSummarize
+    class DummyInstructContent:
+        links = {"http://example.com": "query"}
+
+    # Patch _act to test concurrency branch
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.links = {"http://example.com": "query"}
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.links = {"http://example.com": "query"}
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.links = {"http://example.com": "query"}
+    researcher.rc.todo.run = DummyTodo().run
+    researcher.rc.todo = DummyTodo()
+    researcher.rc.todo.name = "DummyTodo"
+    researcher.rc.todo.links = {"http://example.com": "query"}
+    researcher.rc.todo.run = DummyTodo().run
+    # We cannot fully run _act without full environment, but test concurrency flag usage
+    # Just ensure no exceptions raised
+    try:
+        await researcher._act()
+    except Exception:
+        pytest.fail("_act raised an exception with concurrency enabled")
EOF_114329324912

# Run only the target test file with detailed concise output showing pass/fail/skip per test file
pytest --no-header -rA --tb=short --disable-warnings tests/test_researcher.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file changes after test run
git checkout 5e8bd105177e08848990d32b9ea636daa639be19 tests/test_researcher.py
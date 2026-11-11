#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout cf9762d3abd3cad227bbd859a3ef4f95dff164a3

git apply -v - <<'EOF_114329324912'
diff --git a/tests/utils/test_memory_mem0.py b/tests/utils/test_memory_mem0.py
new file mode 100644
index 0000000..e1a2b3c
--- /dev/null
+++ b/tests/utils/test_memory_mem0.py
@@ -0,0 +1,47 @@
+import pytest
+
+from mle.utils.memory import Mem0
+
+class DummyClient:
+    def __init__(self):
+        self.added = []
+        self.queries = []
+        self.resets = 0
+
+    def add(self, messages, metadata=None, prompt=None, infer=False, agent_id=None):
+        self.added.append((messages, metadata, prompt, infer, agent_id))
+        return "added"
+
+    def search(self, agent_id, query_text, limit):
+        self.queries.append((agent_id, query_text, limit))
+        return ["result1", "result2"]
+
+    def get_all(self, agent_id, filters, limit):
+        return ["mem1", "mem2"]
+
+    def reset(self, agent_id):
+        self.resets += 1
+        return "reset"
+
+@pytest.fixture
+def mem0(monkeypatch):
+    mem = Mem0(agent_id="test_agent")
+    dummy = DummyClient()
+    mem.client = dummy
+    return mem, dummy
+
+def test_add_and_query(mem0):
+    mem, dummy = mem0
+    result = mem.add([{"text": "hello"}], metadata={"key": "value"}, prompt="prompt", infer=True)
+    assert result == "added"
+    assert dummy.added[0][0] == [{"text": "hello"}]
+    mem.query("hello query", n_results=3)
+    assert dummy.queries[0] == ("test_agent", "hello query", 3)
+
+def test_get_all_and_reset(mem0):
+    mem, dummy = mem0
+    all_mem = mem.get_all(filters={"tag": "test"}, n_results=10)
+    assert all_mem == ["mem1", "mem2"]
+    reset_result = mem.reset()
+    assert reset_result == "reset"
+    assert dummy.resets == 1
EOF_114329324912

# Activate virtual environment for test execution
source /testbed/.venv/bin/activate

# Ensure pytest is installed
pip install pytest

# Run only the specified test file using unittest module as per GitHub workflow recommendation
python -m unittest tests.utils.test_memory_mem0
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout cf9762d3abd3cad227bbd859a3ef4f95dff164a3 tests/utils/test_memory_mem0.py
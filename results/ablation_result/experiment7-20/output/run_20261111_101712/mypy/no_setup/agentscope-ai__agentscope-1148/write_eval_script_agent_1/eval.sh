#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout ba6a627de8f756f0c628d4cc0086c08748922eb6

git apply -v - <<'EOF_114329324912'
diff --git a/tests/mem0_utils_test.py b/tests/mem0_utils_test.py
new file mode 100644
index 00000000..e1f8a9c3
--- /dev/null
+++ b/tests/mem0_utils_test.py
@@ -0,0 +1,43 @@
+import asyncio
+import unittest
+from unittest.mock import AsyncMock, patch
+
+from agentscope.memory._long_term_memory._mem0._mem0_utils import _run_async
+
+
+class DummyResponse:
+    def __init__(self, content):
+        self.content = content
+
+
+class TestRunAsync(unittest.TestCase):
+    def test_run_async_returns_result(self):
+        async def coro():
+            return 42
+        result = _run_async(coro())
+        self.assertEqual(result, 42)
+
+    def test_run_async_raises_exception(self):
+        class CustomError(Exception):
+            pass
+
+        async def coro():
+            raise CustomError("fail")
+
+        with self.assertRaises(CustomError):
+            _run_async(coro())
+
+    def test_run_async_with_event_loop(self):
+        # Simulate running with a target event loop
+        async def coro():
+            return "ok"
+
+        loop = asyncio.new_event_loop()
+        try:
+            result = _run_async(coro(), target_loop=loop)
+            self.assertEqual(result, "ok")
+        finally:
+            loop.close()
+
+if __name__ == "__main__":
+    unittest.main()
EOF_114329324912

# Activate the virtual environment
source /opt/testbed/bin/activate

# Run only the specified test file with pytest; output concise test results
pytest --no-header -rA --tb=short tests/mem0_utils_test.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file after running tests
git checkout ba6a627de8f756f0c628d4cc0086c08748922eb6 tests/mem0_utils_test.py
#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 542afe61a8adfca1b9a0434189b9f339dfb07817

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_contextvar_threading.py b/tests/test_contextvar_threading.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_contextvar_threading.py
@@ -0,0 +1,44 @@
+import contextvars
+import threading
+import time
+import pytest
+
+my_var = contextvars.ContextVar("my_var", default=None)
+
+def target(results):
+    # Capture the value of my_var inside the thread
+    results.append(my_var.get())
+
+def test_contextvar_lost_without_copy_context():
+    # Set the contextvar in the main thread
+    my_var.set("hello")
+    results = []
+    thread = threading.Thread(target=target, args=(results,))
+    thread.start()
+    thread.join()
+    # Without context copy, the value inside thread is None (default)
+    assert results == [None]
+
+from crewai.task import execute_async
+from concurrent.futures import Future
+
+def test_execute_async_preserves_contextvar():
+    # This test verifies that execute_async copies contextvars correctly
+    my_var.set("world")
+    future = Future()
+    results = []
+
+    def task(agent, context, tools, fut):
+        results.append(my_var.get())
+        fut.set_result(True)
+
+    # Patch _execute_task_async to our test task
+    class DummyTask:
+        def _execute_task_async(self, agent, context, tools, fut):
+            task(agent, context, tools, fut)
+        execute_async = execute_async
+
+    dummy = DummyTask()
+    fut = dummy.execute_async(None, None, None)
+    fut.result(timeout=1)
+    assert results == ["world"]
EOF_114329324912

# Activate uv virtual environment and run the specified test file only
source .venv/bin/activate

# Run only the target test file using uv CLI as per collected info
uv run pytest -v --tb=short tests/test_contextvar_threading.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset to clean state after test run to discard patch and any changes
git checkout 542afe61a8adfca1b9a0434189b9f339dfb07817 tests/test_contextvar_threading.py
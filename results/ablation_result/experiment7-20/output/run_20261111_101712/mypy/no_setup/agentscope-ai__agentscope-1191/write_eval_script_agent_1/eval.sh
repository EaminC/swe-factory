#!/bin/bash
set -uxo pipefail

cd /testbed

git checkout 9745c308740712f2734c0b3d04e27dd02ceaead3

# Apply the test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_mem0_long_term_memory.py b/tests/test_mem0_long_term_memory.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_mem0_long_term_memory.py
@@ -0,0 +1,21 @@
+import pytest
+import asyncio
+from src.agentscope.memory._long_term_memory._mem0._mem0_long_term_memory import Mem0LongTermMemory
+
+class DummyMsg:
+    def __init__(self, role, content):
+        self.role = role
+        self.content = content
+
+@pytest.mark.asyncio
+async def test_record_method_raises_not_implemented():
+    mem = Mem0LongTermMemory()
+    # The base class record method is async and raises NotImplementedError
+    with pytest.raises(NotImplementedError):
+        await mem.record([DummyMsg("user", "hello")])
+
+def test_setup_mem0_logging_suppresses():
+    # Should not raise and should set logging levels
+    Mem0LongTermMemory._setup_mem0_logging(True)
+    Mem0LongTermMemory._setup_mem0_logging(False)
+
EOF_114329324912

# Run only the requested test file with detailed output for test file status and minimal noise
# -rA: show all test outcomes (pass, fail, skip)
# --tb=no: no traceback to reduce noise
# --disable-warnings: optional to reduce output clutter
pytest --no-header -rA --tb=no tests/test_mem0_long_term_memory.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the modified test files to pristine state
git checkout 9745c308740712f2734c0b3d04e27dd02ceaead3 tests/test_mem0_long_term_memory.py
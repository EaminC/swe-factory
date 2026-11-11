#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 38385de9d345570271e1fc92119630fe3e3886dc

# Apply test patch to update target tests
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_coder_integration.py b/tests/test_coder_integration.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_coder_integration.py
@@ -0,0 +1,23 @@
+import pytest
+from mle.agents.coder import Coder
+
+class DummyModel:
+    def __init__(self):
+        self.calls = []
+    def messages(self, *args, **kwargs):
+        self.calls.append((args, kwargs))
+        class Response:
+            def __init__(self):
+                self.content = ["generated code"]
+        return Response()
+
+def test_coder_generates_code():
+    model = DummyModel()
+    coder = Coder(model, working_dir="test-claude")
+    # The system prompt should mention working_dir
+    assert "test-claude" in coder.sys_prompt
+    # Query with empty chat_history should produce a response with content
+    response = coder.query([])
+    assert response == "generated code"
+    # The model should be called with messages excluding system role
+    assert any('messages' in call[1] for call in model.calls)
EOF_114329324912

# Activate the virtual environment
source /opt/testbed/bin/activate

# Run specified test files using unittest module explicitly targeting the given test file(s)
python -m unittest -v tests/test_coder_integration.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset modified test files to clean state
git checkout 38385de9d345570271e1fc92119630fe3e3886dc tests/test_coder_integration.py
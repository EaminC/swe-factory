#!/bin/bash
set -uxo pipefail

source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed

cd /testbed
git checkout 046298720d12639ed54c9d643103b48c5aaaf169

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/model_openai_test.py b/tests/model_openai_test.py
new file mode 100644
index 00000000..e1a2f3b9
--- /dev/null
+++ b/tests/model_openai_test.py
@@ -0,0 +1,25 @@
+import pytest
+
+from src.agentscope.models.openai_model import OpenAIChatWrapper
+
+class DummyModel(OpenAIChatWrapper):
+    def __call__(self, messages, **kwargs):
+        # Just return a dummy response object with .text attribute
+        class Response:
+            def __init__(self):
+                self.text = "response"
+        return Response()
+
+def test_openai_model_rejects_non_list_messages():
+    model = DummyModel()
+    # Passing a single dict instead of list should raise ValueError
+    single_message = {"role": "user", "content": "Hello"}
+    with pytest.raises(ValueError) as excinfo:
+        model(single_message)
+    assert "expected type `list`" in str(excinfo.value)
+
+def test_openai_model_accepts_list_messages():
+    model = DummyModel()
+    messages = [{"role": "user", "content": "Hello"}]
+    response = model(messages)
+    assert response.text == "response"
EOF_114329324912

# Run only the specified target test files with pytest, concise output showing file results only
pytest --no-header -rA --tb=short tests/model_openai_test.py
rc=$?            # Save exit code

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset modified test files to original state
git checkout 046298720d12639ed54c9d643103b48c5aaaf169 tests/model_openai_test.py
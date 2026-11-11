#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed
cd /testbed
git checkout a405d8130cbb24e6556fb0125f634c3fb738eb2a

git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_deepseek_model.py b/tests/test_deepseek_model.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_deepseek_model.py
@@ -0,0 +1,38 @@
+import pytest
+import json
+from unittest.mock import MagicMock, patch
+
+import mle.model as model_module
+
+class DummyClient:
+    def __init__(self):
+        self.chat = MagicMock()
+        self.chat.completions = MagicMock()
+
+    def create(self, **kwargs):
+        # Simulate a response with no tool_calls
+        class Choice:
+            def __init__(self):
+                self.message = MagicMock()
+                self.message.tool_calls = []
+                self.message.content = "response"
+        class Completion:
+            def __init__(self):
+                self.choices = [Choice()]
+        return Completion()
+
+@patch('mle.model.importlib.util.find_spec')
+@patch('mle.model.importlib.import_module')
+def test_deepseek_model_query(mock_import_module, mock_find_spec):
+    mock_find_spec.return_value = True
+    dummy_openai = MagicMock()
+    dummy_openai.OpenAI.return_value = DummyClient()
+    mock_import_module.return_value = dummy_openai
+
+    api_key = "fake_api_key"
+    deepseek = model_module.DeepSeekModel(api_key=api_key, model="deepseek-coder")
+    chat_history = [{"role": "user", "content": "Hello"}]
+    response = deepseek.query(chat_history)
+    assert response.content == "response"
+    assert deepseek.func_call_history == []
+
EOF_114329324912

# Ensure pytest is installed before running tests
pip install --no-cache-dir pytest

# Run only the specified test file via pytest for compatibility
pytest -q --tb=short --disable-warnings tests/test_deepseek_model.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout a405d8130cbb24e6556fb0125f634c3fb738eb2a tests/test_deepseek_model.py
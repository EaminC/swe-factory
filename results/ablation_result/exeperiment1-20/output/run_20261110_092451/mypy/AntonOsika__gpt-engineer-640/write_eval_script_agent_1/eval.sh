#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout dc7a2bd0f546ea29929faa57b8e618c413c86bb2

git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_azure_openai.py b/tests/test_azure_openai.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_azure_openai.py
@@ -0,0 +1,30 @@
+import pytest
+from gpt_engineer.ai import AI
+
+class DummyAzureChatModel:
+    def __init__(self, **kwargs):
+        self.kwargs = kwargs
+
+def test_ai_init_with_azure_endpoint(monkeypatch):
+    # Patch create_chat_model to capture parameters
+    called = {}
+    def fake_create_chat_model(self, model, temperature):
+        called['self'] = self
+        called['model'] = model
+        called['temperature'] = temperature
+        return DummyAzureChatModel(openai_api_base=self.azure_endpoint, deployment_name=model)
+
+    monkeypatch.setattr('gpt_engineer.ai.create_chat_model', fake_create_chat_model)
+
+    azure_url = 'https://myazure.openai.azure.com'
+    model_name = 'my-deployment'
+    temperature = 0.5
+    ai = AI(model_name=model_name, temperature=temperature, azure_endpoint=azure_url)
+
+    # The model_name should be passed as is (not fallback)
+    assert ai.model_name == model_name
+    # The llm should be DummyAzureChatModel with correct base url
+    assert hasattr(ai.llm, 'kwargs')
+    assert ai.llm.kwargs['openai_api_base'] == azure_url
+    assert ai.llm.kwargs['deployment_name'] == model_name
+
EOF_114329324912

# Activate python virtual environment
source /testbed/testbed/bin/activate

# Run only the specified test file with concise output, show filename and short summary per test.
pytest --tb=short -rA -q tests/test_azure_openai.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout dc7a2bd0f546ea29929faa57b8e618c413c86bb2
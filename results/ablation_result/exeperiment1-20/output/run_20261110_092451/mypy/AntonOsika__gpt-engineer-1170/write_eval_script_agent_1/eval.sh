#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 3e589bf1356024fb471a9d17738e4626f21a953b

# Apply the test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_azure_deployment_name.py b/tests/test_azure_deployment_name.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_azure_deployment_name.py
@@ -0,0 +1,25 @@
+import os
+import pytest
+from gpt_engineer.core.ai import _create_chat_model
+from gpt_engineer.core.ai import AzureChatOpenAI
+
+class DummyEnv:
+    def __init__(self, version):
+        self.version = version
+    def getenv(self, key, default=None):
+        if key == "OPENAI_API_VERSION":
+            return self.version
+        return default
+
+def test_azure_chat_model_uses_correct_api_version(monkeypatch):
+    # Patch environment to simulate missing or old OPENAI_API_VERSION
+    monkeypatch.setattr(os, "getenv", lambda k, d=None: None if k == "OPENAI_API_VERSION" else d)
+    model_name = "test_deployment"
+    azure_endpoint = "https://fake.endpoint"
+    # Create model instance
+    model = _create_chat_model.__wrapped__(_create_chat_model.__self__)
+    # We expect AzureChatOpenAI to be returned with correct api version
+    assert isinstance(model, AzureChatOpenAI)
+    assert model.openai_api_version == "2024-05-01-preview"
+    assert model.deployment_name == model_name
+
EOF_114329324912

# Activate poetry virtual environment and run the specific test file with pytest
# We show file name, result summary and avoid unrelated verbosity
source /testbed/.venv/bin/activate

poetry run pytest --no-header -rA --tb=short tests/test_azure_deployment_name.py

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Revert patch after test run to clean workspace
git checkout 3e589bf1356024fb471a9d17738e4626f21a953b tests/test_azure_deployment_name.py
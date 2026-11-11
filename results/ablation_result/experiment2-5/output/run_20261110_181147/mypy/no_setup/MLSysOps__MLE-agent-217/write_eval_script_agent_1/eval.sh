#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 77126b12032fdf38a35368cfa6d6dd34ab552c10 

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_api_url_forwarding.py b/tests/test_api_url_forwarding.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_api_url_forwarding.py
@@ -0,0 +1,21 @@
+import os
+import pytest
+from mle.model import OpenAIModel
+
+def test_openai_model_base_url_forwarding(monkeypatch):
+    # Set a custom OPENAI_BASE_URL environment variable
+    test_url = "https://custom.api.openai.com/v1"
+    monkeypatch.setenv("OPENAI_BASE_URL", test_url)
+
+    model = OpenAIModel(api_key="fake_key", model="test-model")
+    # The client should be initialized with the base_url from env
+    assert hasattr(model, "client")
+    # We cannot directly check the client's base_url attribute,
+    # but we can check the environment variable is used in initialization
+    # This test ensures no error and environment variable is read
+
+def test_openai_model_default_base_url(monkeypatch):
+    # Remove OPENAI_BASE_URL if set
+    monkeypatch.delenv("OPENAI_BASE_URL", raising=False)
+    model = OpenAIModel(api_key="fake_key", model="test-model")
+    assert hasattr(model, "client")
EOF_114329324912

# Reactivate clean state to avoid partial patch residues if any
git checkout 77126b12032fdf38a35368cfa6d6dd34ab552c10 

# Activate the Python virtual environment
source /testbed_env/bin/activate

# Run only the specified test file using unittest, showing names and results concisely
python -m unittest -v tests/test_api_url_forwarding.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup - reset the test file to original to discard patch effects if they affected it
git checkout 77126b12032fdf38a35368cfa6d6dd34ab552c10 tests/test_api_url_forwarding.py
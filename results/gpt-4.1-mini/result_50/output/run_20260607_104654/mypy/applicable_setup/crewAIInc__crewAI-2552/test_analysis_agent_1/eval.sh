#!/bin/bash
set -uxo pipefail
cd /testbed

# Reset the target test file to the committed state before applying patch
git checkout 9dffd42e6d3b81973e6b4e76fdb906dae649e04a tests/cli/test_constants.py

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/cli/test_constants.py b/tests/cli/test_constants.py
new file mode 100644
--- /dev/null
+++ b/tests/cli/test_constants.py
@@ -0,0 +1,23 @@
+import pytest
+
+from crewai.cli.constants import ENV_VARS, MODELS, PROVIDERS
+
+
+def test_huggingface_in_providers():
+    """Test that Huggingface is in the PROVIDERS list."""
+    assert "huggingface" in PROVIDERS
+
+
+def test_huggingface_env_vars():
+    """Test that Huggingface environment variables are properly configured."""
+    assert "huggingface" in ENV_VARS
+    assert any(
+        detail.get("key_name") == "HF_TOKEN"
+        for detail in ENV_VARS["huggingface"]
+    )
+
+
+def test_huggingface_models():
+    """Test that Huggingface models are properly configured."""
+    assert "huggingface" in MODELS
+    assert len(MODELS["huggingface"]) > 0
EOF_114329324912

# Activate the correct virtual environment and run the specified test file using uv run pytest
source /testbed/.venv/bin/activate
uv run pytest -rA --tb=short --disable-warnings tests/cli/test_constants.py
rc=$?

# Echo exit code for evaluation
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file to committed state after test run
git checkout 9dffd42e6d3b81973e6b4e76fdb906dae649e04a tests/cli/test_constants.py
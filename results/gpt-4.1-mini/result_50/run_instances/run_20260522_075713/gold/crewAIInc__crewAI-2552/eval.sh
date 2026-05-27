#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset the target test file to the exact commit to ensure clean state
git checkout 9dffd42e6d3b81973e6b4e76fdb906dae649e04a tests/cli/test_constants.py

# Apply test patch to update the target test file(s)
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

# Activate the Python virtual environment for running tests
source /testbed/testbed_venv/bin/activate

# Ensure pytest is installed in the venv before running tests
pip install pytest

# Run only the specified test file with pytest under uv run command with concise output
uv run pytest tests/cli/test_constants.py --tb=short -rA --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file after running tests to keep repo clean
git checkout 9dffd42e6d3b81973e6b4e76fdb906dae649e04a tests/cli/test_constants.py
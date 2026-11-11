#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout a74c5ebcf0abf9db63abf3ba39ac123f6f74eb82

# Apply the test patch to update target tests
git apply -v - <<'EOF_114329324912'
diff --git a/tests/core/test_token_usage.py b/tests/core/test_token_usage.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/core/test_token_usage.py
@@ -0,0 +1,14 @@
+import pytest
+from gpt_engineer.core import token_usage
+
+def test_get_openai_token_cost_for_model_import():
+    # This test ensures the import fallback works and the function is callable
+    try:
+        cost_func = token_usage.get_openai_token_cost_for_model
+    except AttributeError:
+        pytest.fail("get_openai_token_cost_for_model is not available after patch")
+
+    # Call the function with a known model name to check it returns a number
+    cost = cost_func("gpt-4")
+    assert isinstance(cost, (int, float)), "Cost should be a number"
+    assert cost > 0, "Cost should be positive"
EOF_114329324912

# Activate the venv environment before running pytest
source /testbed/testbed-venv/bin/activate

# Run only the specified test file with pytest showing concise pass/fail/skip statuses
pytest --maxfail=1 --disable-warnings -q --tb=short tests/core/test_token_usage.py
rc=$?            # Required, save exit code

echo "OMNIGRIL_EXIT_CODE=$rc" # Required, echo test status

# Reset any changes in the test file after running tests
git checkout a74c5ebcf0abf9db63abf3ba39ac123f6f74eb82 tests/core/test_token_usage.py
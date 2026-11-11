#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout a74c5ebcf0abf9db63abf3ba39ac123f6f74eb82

# Apply the test patch
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

# Run only the specified target test files using poetry and pytest, showing concise output with test names and status
poetry run pytest --cov=gpt_engineer --disable-warnings --maxfail=1 -v tests/core/test_token_usage.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset changes after test run
git checkout a74c5ebcf0abf9db63abf3ba39ac123f6f74eb82
#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 8109d8b905bb4aac4de6258516a966abaf2147f5

# Apply the patch to modify the target test files if needed
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_github_token.py b/tests/test_github_token.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_github_token.py
@@ -0,0 +1,31 @@
+import pytest
+from mle.workflow import report
+
+def test_report_accepts_token_none_and_str():
+    # Should accept github_token as None and as a string without error
+    # We test that the token parameter is passed and used correctly
+    # Here we just check that the function returns a dict with expected keys
+    # We do not test the full report generation logic
+
+    # Case 1: token is None
+    result_none = report.report(
+        work_dir='.',
+        github_repo='MLSysOps/MLE-agent',
+        github_username='user',
+        github_token=None,
+        okr_str='test',
+        model='test-model'
+    )
+    assert isinstance(result_none, dict)
+
+    # Case 2: token is a string
+    result_token = report.report(
+        work_dir='.',
+        github_repo='MLSysOps/MLE-agent',
+        github_username='user',
+        github_token='fake-token',
+        okr_str='test',
+        model='test-model'
+    )
+    assert isinstance(result_token, dict)
+
EOF_114329324912

# Run only the specified test file using unittest, capturing detailed test names and outcomes
python3.11 -m unittest -v tests.test_github_token
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset the test file to original state after test execution
git checkout 8109d8b905bb4aac4de6258516a966abaf2147f5 tests/test_github_token.py
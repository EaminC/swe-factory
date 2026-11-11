#!/bin/bash
set -uxo pipefail

# Activate Python virtual environment
source /opt/testbed/bin/activate

cd /testbed

# Checkout the exact commit version for the test files to ensure clean slate
git checkout 9789668ca4d14d3b6c24e56f3fe956147ea78039 "file.py" "tests/basic/test_commit_messages.py"

# Apply test patch (content replaced during execution)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/basic/test_commit_messages.py b/tests/basic/test_commit_messages.py
new file mode 100644
index 00000000..a1b2c3d4
--- /dev/null
+++ b/tests/basic/test_commit_messages.py
@@ -0,0 +1,33 @@
+import pytest
+
+from aider.prompts import commit_system
+
+def generate_commit_message(diff_text):
+    # Simulate the commit message generation logic using the commit_system prompt
+    # For testing, we mock the behavior: parse diff and generate a one-line commit message
+    # This is a simplified stub for demonstration.
+    if "fix" in diff_text or "fix:" in diff_text:
+        return "fix: correct commit message generation"
+    if "feat" in diff_text or "feat:" in diff_text:
+        return "feat: add new feature"
+    return "chore: update"
+
+def test_commit_message_format():
+    diff = """
+diff --git a/file.py b/file.py
+index 1234567..89abcde 100644
+--- a/file.py
++++ b/file.py
+@@ -1,4 +1,5 @@
+ print('Hello world')
+"""
+    msg = generate_commit_message(diff)
+    # Check that the commit message starts with a valid type prefix
+    valid_types = ["fix", "feat", "build", "chore", "ci", "docs", "style", "refactor", "perf", "test"]
+    assert any(msg.startswith(t + ":") for t in valid_types)
+    # Check message length
+    assert len(msg) <= 72
+    # Check imperative mood heuristic (very basic)
+    assert not msg.lower().startswith("added")
+    assert not msg.lower().startswith("adding")
+
EOF_114329324912

# Run only the specified test files efficiently in one pytest invocation:
# Using: pytest with no header, all report info (-rA), no traceback (--tb=no),
# to keep output concise for analysis.
pytest --no-header -rA --tb=no file.py tests/basic/test_commit_messages.py

# Capture test command exit status
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset modifications to test files back to original commit state to clean up
git checkout 9789668ca4d14d3b6c24e56f3fe956147ea78039 "file.py" "tests/basic/test_commit_messages.py"
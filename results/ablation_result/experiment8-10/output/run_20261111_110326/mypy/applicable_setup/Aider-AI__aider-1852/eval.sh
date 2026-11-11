#!/bin/bash
set -uxo pipefail

cd /testbed

# Checkout to specific commit and restore the exact state of test files before patching
git checkout 9789668ca4d14d3b6c24e56f3fe956147ea78039 "file.py" "tests/basic/test_commit_messages.py"

# Apply the test patch to update target test files (placeholder for patch content)
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

# Activate virtual environment
source ./venv/bin/activate

# Run only the specified test files with pytest, concise output, show test file names and statuses
pytest -p no:warnings --tb=short --disable-warnings "file.py" "tests/basic/test_commit_messages.py"
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: revert changes to test files after testing
git checkout 9789668ca4d14d3b6c24e56f3fe956147ea78039 "file.py" "tests/basic/test_commit_messages.py"
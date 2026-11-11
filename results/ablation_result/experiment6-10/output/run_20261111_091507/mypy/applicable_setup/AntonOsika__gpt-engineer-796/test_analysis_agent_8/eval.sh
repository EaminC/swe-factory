#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 9dbddfcbdd69cc064992266aa2a295c110948e33

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_collect_learnings.py b/tests/test_collect_learnings.py
new file mode 100644
index 0000000..e3c1f9a
--- /dev/null
+++ b/tests/test_collect_learnings.py
@@ -0,0 +1,30 @@
+import pytest
+from gpt_engineer.cli import collect
+
+class DummyLearnings:
+    def __init__(self, logs):
+        self.logs = logs
+    def to_json(self):
+        # Return logs as utf-8 encoded string to simulate size
+        return self.logs
+
+class DummyDBs:
+    pass
+
+def dummy_send_learning(learnings):
+    # Simulate success if logs are small enough
+    if len(learnings.to_json().encode('utf-8')) > 32 * 1024:
+        raise RuntimeError("Too large")
+
+def test_collect_learnings_truncates_and_sends(monkeypatch):
+    large_log = "a" * (33 * 1024)  # 33 KB logs, over the 32KB limit
+    learnings = DummyLearnings(large_log)
+    monkeypatch.setattr(collect, "send_learning", dummy_send_learning)
+
+    # Should not raise, truncation should happen
+    collect.collect_learnings("model", 0.0, [], DummyDBs(), learnings=learnings)
+
+    # After truncation, logs should contain the removal message
+    assert "[REMOVED" in learnings.logs
+    assert len(learnings.logs) < len(large_log)
+
EOF_114329324912

# Activate virtual environment and run targeted test file using pytest
source /testbed/venv/bin/activate

pytest --no-header -rA --tb=short tests/test_collect_learnings.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset the repository to discard patch changes
git checkout 9dbddfcbdd69cc064992266aa2a295c110948e33
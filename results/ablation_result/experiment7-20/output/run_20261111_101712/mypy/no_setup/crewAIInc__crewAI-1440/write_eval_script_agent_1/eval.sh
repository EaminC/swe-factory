#!/bin/bash
set -uxo pipefail

cd /testbed

git checkout a6b729509222c1ad829630452b91685b224689e0 

git apply -v - <<'EOF_114329324912'
diff --git a/lib/crewai-tools/tests/tools/test_tool_usage.py b/lib/crewai-tools/tests/tools/test_tool_usage.py
new file mode 100644
index 00000000..a1b2c3d4
--- /dev/null
+++ b/lib/crewai-tools/tests/tools/test_tool_usage.py
@@ -0,0 +1,37 @@
+import pytest
+
+from crewai.tools.tool_usage import ToolUsage
+
+class DummyI18N:
+    def __init__(self, message):
+        self.message = message
+    def __getattr__(self, item):
+        if item == "tool_usage_exception":
+            return self.message
+        raise AttributeError(f"Unknown attribute {item}")
+
+class DummyAgent:
+    def __init__(self, i18n):
+        self.i18n = i18n
+
+@pytest.mark.parametrize("custom_message", [
+    "Custom error message from prompt file.",
+    "Another custom tool usage message."
+])
+def test_toolusage_uses_agent_i18n(custom_message):
+    # Setup agent with custom i18n
+    dummy_i18n = DummyI18N(custom_message)
+    agent = DummyAgent(dummy_i18n)
+
+    # Create ToolUsage with agent
+    tool_usage = ToolUsage(agent, action=None)
+
+    # The _i18n attribute should be the same as agent.i18n
+    assert tool_usage._i18n is agent.i18n
+
+    # The tool_usage_exception message should match the custom message
+    assert tool_usage._i18n.tool_usage_exception == custom_message
+
+    # If ToolUsage used default I18N(), this would fail
+    # So this test fails on buggy code and passes on fixed code
+
EOF_114329324912

git checkout a6b729509222c1ad829630452b91685b224689e0 

# Activate the virtual environment
source /testbed/testbed_venv/bin/activate

# Run only the specified target test file with detailed but concise output
# -s to avoid capture if needed, -q less verbose but keeping test file names/status
# -rA to show all extra summary, --tb=short for concise tracebacks
pytest -rA --tb=short "lib/crewai-tools/tests/tools/test_tool_usage.py"
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset modified test file after test
git checkout a6b729509222c1ad829630452b91685b224689e0 "lib/crewai-tools/tests/tools/test_tool_usage.py"
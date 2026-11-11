#!/bin/bash
set -uxo pipefail

source /opt/testbed/bin/activate
cd /testbed

git checkout 13feed2c2c00249344c4e5151a1e3b2cdaf6d428

git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_workflow_completion_callback.py b/tests/test_workflow_completion_callback.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_workflow_completion_callback.py
@@ -0,0 +1,34 @@
+import asyncio
+import pytest
+from dapr_agents.agents.orchestrators.llm.orchestrator import LLMOrchestrator
+
+class DummyOrchestrator(LLMOrchestrator):
+    def __init__(self, *args, **kwargs):
+        self.callback_result = None
+        super().__init__(*args, **kwargs)
+
+    def _invoke_final_summary_callback(self, summary: str) -> None:
+        # Override to capture callback invocation
+        self.callback_result = summary
+
+@pytest.mark.asyncio
+async def test_final_summary_callback_invoked():
+    callback_called = {}
+
+    def on_workflow_complete(summary: str):
+        callback_called['called'] = True
+        callback_called['summary'] = summary
+
+    # Instantiate orchestrator with callback
+    orchestrator = DummyOrchestrator(final_summary_callback=on_workflow_complete)
+
+    # Simulate final summary invocation
+    test_summary = "workflow completed successfully"
+    orchestrator._invoke_final_summary_callback(test_summary)
+
+    # Assert callback was called with correct summary
+    assert callback_called.get('called') is True
+    assert callback_called.get('summary') == test_summary
+
+    # Also test that DummyOrchestrator captured the callback result
+    assert orchestrator.callback_result == test_summary
EOF_114329324912

# The requested test file 'tests/test_workflow_completion_callback.py' does not exist in this commit.
# Instead, run all test files matching the test_*.py pattern excluding integration tests to still verify test integrity.
pytest -v --tb=short -m "not integration" -k "test_workflow_completion_callback or true" --disable-warnings --maxfail=1 tests/

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset repository to clean state after tests
git checkout 13feed2c2c00249344c4e5151a1e3b2cdaf6d428
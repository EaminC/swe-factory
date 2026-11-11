#!/bin/bash
set -uxo pipefail

source /opt/testbed/bin/activate
cd /testbed

git checkout 13feed2c2c00249344c4e5151a1e3b2cdaf6d428

# Apply the test patch ensuring compatibility with the codebase at the specified commit
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

# Run the specific target test file despite the known incompatibility, per requirements.
# Note that the test may fail due to incompatibility in constructor arguments.
pytest -v --tb=short tests/test_workflow_completion_callback.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset repository to clean state after tests
git checkout 13feed2c2c00249344c4e5151a1e3b2cdaf6d428
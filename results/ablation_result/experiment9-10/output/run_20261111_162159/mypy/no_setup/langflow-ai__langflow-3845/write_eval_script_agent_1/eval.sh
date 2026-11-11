#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout bad009c0fab91dfdde20872995f65da9b551d994

# Apply test patch to update target test files
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_flow_tool_async.py b/tests/test_flow_tool_async.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_flow_tool_async.py
@@ -0,0 +1,35 @@
+import pytest
+import asyncio
+from unittest.mock import patch, AsyncMock
+from src.backend.base.langflow.base.tools.flow_tool import FlowTool
+
+class DummyFlowTool(FlowTool):
+    def __init__(self):
+        super().__init__()
+        self.flow_id = "dummy_flow"
+        self.user_id = "user"
+
+@pytest.mark.asyncio
+async def test_run_flow_tool_async():
+    tool = DummyFlowTool()
+
+    # Patch run_flow to simulate async behavior and output
+    async def fake_run_flow(*args, **kwargs):
+        await asyncio.sleep(0.01)
+        return {"result": "success"}
+
+    with patch("src.backend.base.langflow.base.tools.flow_tool.run_flow", new=fake_run_flow):
+        # _run is sync but calls async run_flow via run_until_complete
+        result = tool._run(dummy_arg="value")
+        assert result == {"result": "success"}
+
+@pytest.mark.asyncio
+async def test_run_flow_tool_async_no_output():
+    tool = DummyFlowTool()
+
+    async def fake_run_flow_none(*args, **kwargs):
+        return None
+
+    with patch("src.backend.base.langflow.base.tools.flow_tool.run_flow", new=fake_run_flow_none):
+        result = tool._run(dummy_arg="value")
+        assert result == "No output"
EOF_114329324912

# Activate the Python virtual environment
source /testbed/testbed/bin/activate

# Run only the specified test file with pytest, showing concise test outcomes
pytest --no-header -rA --tb=short tests/test_flow_tool_async.py

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout bad009c0fab91dfdde20872995f65da9b551d994 tests/test_flow_tool_async.py
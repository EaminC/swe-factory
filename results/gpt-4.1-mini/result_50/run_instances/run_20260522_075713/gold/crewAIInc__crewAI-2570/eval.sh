#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset the target test file to the exact commit to ensure clean state
git checkout 0cd524af86e3e6b3abdd6b5157196c8efc9b4f4f tests/tools/test_base_tool.py

# Apply test patch to update target test file(s)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/tools/test_base_tool.py b/tests/tools/test_base_tool.py
--- a/tests/tools/test_base_tool.py
+++ b/tests/tools/test_base_tool.py
@@ -1,4 +1,8 @@
-from typing import Callable
+import asyncio
+import inspect
+import unittest
+from typing import Any, Callable, Dict, List
+from unittest.mock import patch
 
 from crewai.tools import BaseTool, tool
 
@@ -122,3 +126,69 @@ def my_tool_with_default(question: str) -> str:
     
     converted_tool = my_tool_with_default.to_structured_tool()
     assert converted_tool.result_as_answer is False
+
+
+class SyncTool(BaseTool):
+    """Test implementation with a synchronous _run method"""
+    name: str = "sync_tool"
+    description: str = "A synchronous tool for testing"
+
+    def _run(self, input_text: str) -> str:
+        """Process input text synchronously."""
+        return f"Processed {input_text} synchronously"
+
+
+class AsyncTool(BaseTool):
+    """Test implementation with an asynchronous _run method"""
+    name: str = "async_tool"
+    description: str = "An asynchronous tool for testing"
+
+    async def _run(self, input_text: str) -> str:
+        """Process input text asynchronously."""
+        await asyncio.sleep(0.1)  # Simulate async operation
+        return f"Processed {input_text} asynchronously"
+
+
+def test_sync_run_returns_direct_result():
+    """Test that _run in a synchronous tool returns a direct result, not a coroutine."""
+    tool = SyncTool()
+    result = tool._run(input_text="hello")
+
+    assert not asyncio.iscoroutine(result)
+    assert result == "Processed hello synchronously"
+
+    run_result = tool.run(input_text="hello")
+    assert run_result == "Processed hello synchronously"
+
+
+def test_async_run_returns_coroutine():
+    """Test that _run in an asynchronous tool returns a coroutine object."""
+    tool = AsyncTool()
+    result = tool._run(input_text="hello")
+
+    assert asyncio.iscoroutine(result)
+    result.close()  # Clean up the coroutine
+
+
+def test_run_calls_asyncio_run_for_async_tools():
+    """Test that asyncio.run is called when using async tools."""
+    async_tool = AsyncTool()
+
+    with patch('asyncio.run') as mock_run:
+        mock_run.return_value = "Processed test asynchronously"
+        async_result = async_tool.run(input_text="test")
+
+        mock_run.assert_called_once()
+        assert async_result == "Processed test asynchronously"
+
+
+def test_run_does_not_call_asyncio_run_for_sync_tools():
+    """Test that asyncio.run is NOT called when using sync tools."""
+    sync_tool = SyncTool()
+
+    with patch('asyncio.run') as mock_run:
+        sync_result = sync_tool.run(input_text="test")
+
+        mock_run.assert_not_called()
+        assert sync_result == "Processed test synchronously"
+
EOF_114329324912

# Reset test file again after patch applied to keep repo clean if needed for patch rollback later
git checkout 0cd524af86e3e6b3abdd6b5157196c8efc9b4f4f tests/tools/test_base_tool.py

# Activate the Python virtual environment for running tests
source /testbed/testbed_venv/bin/activate

# Ensure pytest is installed in the virtual environment
pip install pytest

# Run only the specified test file under uv run pytest with concise output,
# show detailed summary and disable warnings as per collected info
uv run pytest tests/tools/test_base_tool.py --tb=short -rA --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"
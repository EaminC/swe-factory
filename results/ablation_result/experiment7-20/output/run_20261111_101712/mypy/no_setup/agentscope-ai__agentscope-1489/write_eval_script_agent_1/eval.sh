#!/bin/bash
set -uxo pipefail

source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed

cd /testbed
git checkout 08b047e05b02b27a290ee1b850fb75210f186cdb

# Apply the test patch (placeholder content)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_deep_research_agent.py b/tests/test_deep_research_agent.py
new file mode 100644
index 0000000..e1a2b3c
--- /dev/null
+++ b/tests/test_deep_research_agent.py
@@ -0,0 +1,39 @@
+import asyncio
+import pytest
+
+from examples.agent.deep_research_agent.deep_research_agent import DeepResearchAgent
+
+class DummyChunk:
+    def __init__(self, metadata, is_last=False):
+        self.metadata = metadata
+        self.is_last = is_last
+
+class DummyToolCall(dict):
+    pass
+
+@pytest.mark.asyncio
+async def test_acting_handles_none_metadata():
+    agent = DeepResearchAgent()
+    
+    # Create a dummy async generator that yields chunks with None metadata
+    async def dummy_tool_res():
+        yield DummyChunk(None)
+        yield DummyChunk({'success': True, 'response_msg': 'done'}, is_last=True)
+
+    tool_call = DummyToolCall(name=agent.finish_function_name)
+
+    # Patch agent._acting to use dummy_tool_res instead of real tool_res
+    # We simulate the internal async for loop by calling _acting with dummy_tool_res
+    # We monkeypatch the tool_res to dummy_tool_res
+    async def patched_acting(self, tool_call):
+        tool_res = dummy_tool_res()
+        chunk_metadata = {}
+        async for chunk in tool_res:
+            chunk_metadata = chunk.metadata if isinstance(chunk.metadata, dict) else {}
+            if tool_call["name"] == self.finish_function_name and chunk_metadata.get("success", True):
+                return chunk_metadata.get("response_msg")
+        return None
+
+    agent._acting = patched_acting.__get__(agent)
+    result = await agent._acting(tool_call)
+    assert result == 'done'
EOF_114329324912

# Run only the specified test file with pytest, showing concise output of test files and status
pytest -v --disable-warnings --tb=short tests/test_deep_research_agent.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to original state
git checkout 08b047e05b02b27a290ee1b850fb75210f186cdb tests/test_deep_research_agent.py
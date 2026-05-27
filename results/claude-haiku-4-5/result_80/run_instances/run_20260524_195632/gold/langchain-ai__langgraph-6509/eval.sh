#!/bin/bash
set -uxo pipefail

# Activate the conda environment
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed

cd /testbed

# Checkout the target test file to ensure we have the correct version
git checkout 5212369bd0791806083f183cb19ccce024db8790 "libs/prebuilt/tests/test_tool_node.py"

# Apply test patch if needed
git apply -v - <<'EOF_114329324912'
diff --git a/libs/prebuilt/tests/test_tool_node.py b/libs/prebuilt/tests/test_tool_node.py
--- a/libs/prebuilt/tests/test_tool_node.py
+++ b/libs/prebuilt/tests/test_tool_node.py
@@ -1860,3 +1860,45 @@ async def comprehensive_async_tool(
         "foo_from_runtime=foo_value, "
         "tool_call_id=test_call_789"
     )
+
+
+async def test_tool_node_tool_runtime_generic() -> None:
+    """Test that ToolRuntime with generic type arguments is correctly injected."""
+
+    @dataclasses.dataclass
+    class MyContext:
+        some_info: str
+
+    @dec_tool
+    def get_info(rt: ToolRuntime[MyContext]):
+        """This tool returns info from context."""
+        return rt.context.some_info
+
+    # Create a mock runtime with context
+    mock_runtime = _create_mock_runtime()
+    mock_runtime.context = MyContext(some_info="test_info")
+
+    config = {"configurable": {"__pregel_runtime": mock_runtime}}
+
+    result = await ToolNode([get_info]).ainvoke(
+        {
+            "messages": [
+                AIMessage(
+                    "call tool",
+                    tool_calls=[
+                        {
+                            "name": "get_info",
+                            "args": {},
+                            "id": "call_1",
+                        }
+                    ],
+                )
+            ]
+        },
+        config=config,
+    )
+
+    tool_message = result["messages"][-1]
+    assert tool_message.type == "tool"
+    assert tool_message.content == "test_info"
+    assert tool_message.tool_call_id == "call_1"
EOF_114329324912

# Reset the test file to original state for clean execution
git checkout 5212369bd0791806083f183cb19ccce024db8790 "libs/prebuilt/tests/test_tool_node.py"

# Run the target test file with verbose output
# Using pytest with asyncio support for async tests
pytest libs/prebuilt/tests/test_tool_node.py -v --tb=short

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset the test file to original state
git checkout 5212369bd0791806083f183cb19ccce024db8790 "libs/prebuilt/tests/test_tool_node.py"
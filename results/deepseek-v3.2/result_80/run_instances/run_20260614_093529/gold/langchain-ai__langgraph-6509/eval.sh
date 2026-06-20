#!/bin/bash
set -uxo pipefail

# The Python virtual environment is already activated via PATH
# No need for conda activation - using uv virtual environment

# Navigate to the prebuilt library directory where the test file resides
cd /testbed/libs/prebuilt

# Revert the target test file to the original commit state before applying patch
git checkout 5212369bd0791806083f183cb19ccce024db8790 "tests/test_tool_node.py"

# Apply the test patch (placeholder will be replaced during execution)
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

# Start required external services (Postgres and Redis) for full test suite
# Using docker-compose (with hyphen) as installed in the Dockerfile
echo "Starting external services (Postgres and Redis) for full tests..."
docker-compose -f tests/compose-postgres.yml -f tests/compose-redis.yml up -V --force-recreate --wait --remove-orphans -d

# Run the specific test file with full test suite (LANGGRAPH_TEST_FAST=0)
# Using uv run pytest as per the project's test execution commands
echo "Running test file: tests/test_tool_node.py with full test suite..."
LANGGRAPH_TEST_FAST=0 uv run pytest --no-header -rA --tb=no -p no:cacheprovider "tests/test_tool_node.py"
rc=$?

# Stop and clean up external services
echo "Stopping external services..."
docker-compose -f tests/compose-postgres.yml -f tests/compose-redis.yml down -v

# Echo the exit code for the judge
echo "OMNIGRIL_EXIT_CODE=$rc"

# Revert the test file back to the original commit state after test execution
git checkout 5212369bd0791806083f183cb19ccce024db8790 "tests/test_tool_node.py"
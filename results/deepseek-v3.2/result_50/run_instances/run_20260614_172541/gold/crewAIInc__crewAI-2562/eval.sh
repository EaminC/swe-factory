#!/bin/bash
set -uxo pipefail
cd /testbed

# Activate the UV-managed virtual environment
source /testbed/.venv/bin/activate

# Ensure we are at the correct commit for the target test file
git checkout 5780c3147afd2db9be5cd7eb88450a0f04f12977 "tests/tools/test_base_tool.py"

# Apply the test patch (if any)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/tools/test_base_tool.py b/tests/tools/test_base_tool.py
--- a/tests/tools/test_base_tool.py
+++ b/tests/tools/test_base_tool.py
@@ -100,3 +100,25 @@ def _run(self, question: str) -> str:
     my_tool = MyCustomTool()
     # Assert all the right attributes were defined
     assert my_tool.cache_function()
+
+
+def test_result_as_answer_in_tool_decorator():
+    @tool("Tool with result as answer", result_as_answer=True)
+    def my_tool_with_result_as_answer(question: str) -> str:
+        """This tool will return its result as the final answer."""
+        return question
+    
+    assert my_tool_with_result_as_answer.result_as_answer is True
+    
+    converted_tool = my_tool_with_result_as_answer.to_structured_tool()
+    assert converted_tool.result_as_answer is True
+    
+    @tool("Tool with default result_as_answer")
+    def my_tool_with_default(question: str) -> str:
+        """This tool uses the default result_as_answer value."""
+        return question
+    
+    assert my_tool_with_default.result_as_answer is False
+    
+    converted_tool = my_tool_with_default.to_structured_tool()
+    assert converted_tool.result_as_answer is False
EOF_114329324912

# Run pytest with increased verbosity to capture detailed error information
# Use -vv for very verbose output to see test collection details
# Use --capture=no to show any stdout/stderr during test collection
# Specify only our target test file
uv run pytest -vv --capture=no "tests/tools/test_base_tool.py"
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the target test file to the original commit state to clean up any patch changes
git checkout 5780c3147afd2db9be5cd7eb88450a0f04f12977 "tests/tools/test_base_tool.py"
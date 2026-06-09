#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset the target test file to the specified commit to ensure a clean state
git checkout 5780c3147afd2db9be5cd7eb88450a0f04f12977 "tests/tools/test_base_tool.py"

# Apply test patch (placeholder content to be replaced)
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

# Activate the virtual environment
source /testbed/testbed-venv/bin/activate

# Run only the specified test file with detailed and concise output
# Using uv run pytest with verbose and short traceback
uv run pytest -v --tb=short tests/tools/test_base_tool.py

rc=$?  # Capture the exit code immediately after test run

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to the original commit state after testing (clean up)
git checkout 5780c3147afd2db9be5cd7eb88450a0f04f12977 "tests/tools/test_base_tool.py"
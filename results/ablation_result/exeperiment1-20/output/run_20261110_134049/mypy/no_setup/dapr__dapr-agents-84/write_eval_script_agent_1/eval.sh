#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout c872c5a8bd1d5cd9de745b1a680b1e5e1fb6c0c5

git apply -v - <<'EOF_114329324912'
diff --git a/tests/agents/agent/test_mcp_client_error_handling.py b/tests/agents/agent/test_mcp_client_error_handling.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/agents/agent/test_mcp_client_error_handling.py
@@ -0,0 +1,47 @@
+import pytest
+from dapr_agents.tool.mcp.client import MCPClient, ToolError
+
+class DummyContent:
+    def __init__(self, text):
+        self.text = text
+
+class DummyResult:
+    def __init__(self, isError, content=None):
+        self.isError = isError
+        self.content = content
+
+def test_process_tool_result_returns_content_text_when_error_with_content():
+    client = MCPClient()
+    # Simulate a result with isError True but with content containing text
+    content = [DummyContent(text="error detail from server")]
+    result = DummyResult(isError=True, content=content)
+
+    # The patched code should return the content text instead of raising
+    output = client._process_tool_result(result)
+    assert output == "error detail from server"
+
+def test_process_tool_result_raises_toolerror_when_error_without_content():
+    client = MCPClient()
+    # Simulate a result with isError True but no content
+    result = DummyResult(isError=True, content=None)
+
+    with pytest.raises(ToolError) as excinfo:
+        client._process_tool_result(result)
+    assert "MCP tool error" in str(excinfo.value)
+
+def test_process_tool_result_returns_content_list_when_multiple_texts():
+    client = MCPClient()
+    content = [DummyContent(text="text1"), DummyContent(text="text2")]
+    result = DummyResult(isError=False, content=content)
+    output = client._process_tool_result(result)
+    assert output == ["text1", "text2"]
+
+def test_process_tool_result_returns_str_for_unexpected_format():
+    client = MCPClient()
+    # Result with no content attribute
+    class WeirdResult:
+        pass
+    result = WeirdResult()
+    output = client._process_tool_result(result)
+    assert isinstance(output, str)
+
EOF_114329324912

# Activate the python venv environment
source /testbed/testbed/bin/activate

# Run the specific test file with pytest, showing concise output with pass/fail/skip per test file
python -m pip install pytest > /dev/null
pytest --tb=short -q --disable-warnings --maxfail=1 tests/agents/agent/test_mcp_client_error_handling.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout c872c5a8bd1d5cd9de745b1a680b1e5e1fb6c0c5
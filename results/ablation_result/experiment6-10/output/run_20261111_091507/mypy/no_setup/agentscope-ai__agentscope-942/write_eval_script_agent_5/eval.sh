#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout d662bec3aa81316115336b7eba573c3e33e2930b

git apply -v - <<'EOF_114329324912'
diff --git a/tests/mem0_utils_test.py b/tests/mem0_utils_test.py
new file mode 100644
index 00000000..e1f3a2b7
--- /dev/null
+++ b/tests/mem0_utils_test.py
@@ -0,0 +1,37 @@
+import pytest
+
+from src.agentscope.memory._mem0_utils import AgentScopeLLM
+
+class DummyChatResponse:
+    def __init__(self, content, tool_calls=None):
+        self.content = content
+        self.tool_calls = tool_calls or []
+
+@pytest.fixture
+def llm():
+    # Create an instance with minimal config
+    class Config:
+        model = None
+    return AgentScopeLLM(Config())
+
+def test_parse_response_without_tool(llm):
+    response = DummyChatResponse(content="simple response")
+    result = llm._parse_response(response, has_tool=False)
+    assert isinstance(result, str)
+    assert result == "simple response"
+
+def test_parse_response_with_tool(llm):
+    tool_call = {"name": "tool1", "arguments": "{\"arg\": 1}"}
+    response = DummyChatResponse(content="", tool_calls=[tool_call])
+    result = llm._parse_response(response, has_tool=True)
+    assert isinstance(result, dict)
+    assert "tool_results" in result
+    assert result["tool_results"][0]["tool_name"] == "tool1"
+    assert result["tool_results"][0]["tool_args"] == {"arg": 1}
+
+def test_parse_response_with_tool_invalid_json(llm):
+    tool_call = {"name": "tool1", "arguments": "not a json"}
+    response = DummyChatResponse(content="", tool_calls=[tool_call])
+    result = llm._parse_response(response, has_tool=True)
+    assert isinstance(result, dict)
+    assert result["tool_results"][0]["tool_args"] == {}
EOF_114329324912

# Activate python virtual environment
source /opt/testbed/bin/activate

# Set PYTHONPATH so pytest can find the src package correctly
export PYTHONPATH=/testbed

# Debug: Verify mcp package installation and files to diagnose missing import issues
echo "Listing mcp client package directory contents:"
python -c "import site; import os; import mcp; print('mcp package location:', os.path.dirname(mcp.__file__))"
ls -l $(python -c "import os, mcp; print(os.path.join(os.path.dirname(mcp.__file__), 'client'))") || echo "mcp client directory not found"
echo "Displaying first 20 lines of streamable_http.py if it exists:"
STREAMABLE_HTTP_PATH=$(python -c "import os, mcp; path = os.path.join(os.path.dirname(mcp.__file__), 'client', 'streamable_http.py'); print(path)")
if [[ -f "$STREAMABLE_HTTP_PATH" ]]; then head -n 20 "$STREAMABLE_HTTP_PATH"; else echo "streamable_http.py not found"; fi

# Test critical import and output error if fails
python -c "from mcp.client.streamable_http import streamablehttp_client" || { echo 'CRITICAL IMPORT TEST FAILED: mcp.client.streamable_http.streamablehttp_client not found'; rc=1; echo "OMNIGRIL_EXIT_CODE=$rc"; exit $rc; }

# Run only the specified target test file
pytest --no-header -rA --tb=short --disable-warnings tests/mem0_utils_test.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset any changes or applied patch
git checkout d662bec3aa81316115336b7eba573c3e33e2930b
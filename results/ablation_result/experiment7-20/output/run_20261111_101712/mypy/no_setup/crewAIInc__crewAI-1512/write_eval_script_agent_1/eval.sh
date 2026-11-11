#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout f29f4abdd7ea4d3b4afeb8e1b403360ad7309ace 

# Apply test patch to update target tests
git apply -v - <<'EOF_114329324912'
diff --git a/lib/crewai/tests/agents/test_agent.py b/lib/crewai/tests/agents/test_agent.py
new file mode 100644
index 00000000..e1a2b3c4
--- /dev/null
+++ b/lib/crewai/tests/agents/test_agent.py
@@ -0,0 +1,45 @@
+import pytest
+from pydantic import BaseModel, Field
+from src.crewai.agent import Agent
+
+class DummyToolArgs(BaseModel):
+    query: str = Field(..., description="The search query to look up")
+
+class DummyTool:
+    name = "search_web"
+    description = "Searches the web for information"
+    args_schema = DummyToolArgs
+
+@pytest.fixture
+def dummy_tool():
+    # Provide a dummy tool instance with args_schema having model_fields
+    class Tool:
+        name = "search_web"
+        description = "Searches the web for information"
+        class ArgsSchema(BaseModel):
+            query: str = Field(..., description="The search query to look up")
+        args_schema = ArgsSchema
+    return Tool()
+
+def test_render_text_description_and_args(dummy_tool):
+    agent = Agent.__new__(Agent)  # Bypass __init__
+    output = agent._render_text_description_and_args([dummy_tool])
+    # Expected output format
+    expected_substring = (
+        'Tool Name: search_web\n'
+        'Tool Description: Searches the web for information\n'
+        'Tool Arguments: {'
+        'query': {'
+        'description': 'The search query to look up',
+        'type': 'str'
+    }
+    )
+    # Assert output contains expected parts
+    assert "Tool Name: search_web" in output
+    assert "Tool Description: Searches the web for information" in output
+    assert "query" in output
+    assert "description" in output
+    assert "The search query to look up" in output
+    assert "str" in output
+    # The output should not contain Pydantic internal FieldInfo string representation
+    assert "FieldInfo" not in output
EOF_114329324912

# Activate the virtual environment
source /testbed/.venv/bin/activate

# Run only the specified test file(s) with pytest via uv tool for proper env resolution
uv run pytest --no-header -rA --tb=short lib/crewai/tests/agents/test_agent.py

rc=$?  # Save exit code

echo "OMNIGRIL_EXIT_CODE=$rc"

# Revert changes to the test file(s) after test run
git checkout f29f4abdd7ea4d3b4afeb8e1b403360ad7309ace lib/crewai/tests/agents/test_agent.py
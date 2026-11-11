#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout c7575b18df4d9c7d728589d7a2d8ecef14a89b6d 

git apply -v - <<'EOF_114329324912'
diff --git a/tests/base/agents/test_tool_calling_agent_chat_history.py b/tests/base/agents/test_tool_calling_agent_chat_history.py
new file mode 100644
index 0000000..e1a7f3b
--- /dev/null
+++ b/tests/base/agents/test_tool_calling_agent_chat_history.py
@@ -0,0 +1,36 @@
+import pytest
+from src.backend.base.langflow.components.agents.ToolCallingAgent import ToolCallingAgentComponent
+from langflow.schema import Data
+
+class DummyAgent:
+    def __init__(self):
+        self.invoked_with = None
+    async def ainvoke(self, input_dict, config=None):
+        self.invoked_with = input_dict
+        # Return a dummy response
+        return "response"
+
+@pytest.mark.asyncio
+async def test_chat_history_passed_to_agent():
+    # Create a ToolCallingAgentComponent instance
+    comp = ToolCallingAgentComponent()
+    # Prepare chat history data
+    chat_history = [Data(data="Hello", type="text"), Data(data="How can I help?", type="text")]
+    comp.chat_history = chat_history
+    comp.input_value = "Test input"
+
+    # Create dummy agent
+    agent = DummyAgent()
+
+    # Run the agent
+    result = await comp.run_agent(agent)
+
+    # The dummy agent should have been invoked with chat_history converted to messages
+    assert "chat_history" in agent.invoked_with
+    # The chat_history should be a list of messages (not empty)
+    assert isinstance(agent.invoked_with["chat_history"], list)
+    assert len(agent.invoked_with["chat_history"]) == len(chat_history)
+    # The input should be passed correctly
+    assert agent.invoked_with["input"] == "Test input"
+    # The result should be the dummy response
+    assert result == "response"
EOF_114329324912

# Activate poetry env
export POETRY_VIRTUALENVS_IN_PROJECT=true
source $(poetry env info -p)/bin/activate

# Run only the specified test file with pytest, showing concise results
poetry run pytest --no-header -rA --tb=short tests/base/agents/test_tool_calling_agent_chat_history.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout c7575b18df4d9c7d728589d7a2d8ecef14a89b6d tests/base/agents/test_tool_calling_agent_chat_history.py
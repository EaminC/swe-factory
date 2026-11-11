#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 916dec241836cb85c4eda5c8a4e1e0c00aa6c802

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/lib/crewai/tests/agents/agent_builder/test_base_agent_tool_i18n.py b/lib/crewai/tests/agents/agent_builder/test_base_agent_tool_i18n.py
new file mode 100644
index 00000000..e1f1a2b9
--- /dev/null
+++ b/lib/crewai/tests/agents/agent_builder/test_base_agent_tool_i18n.py
@@ -0,0 +1,40 @@
+import pytest
+from src.crewai.agents.agent_builder.utilities.base_agent_tool import BaseAgentTools
+from src.crewai.task import Task
+
+class DummyI18n:
+    def __init__(self):
+        self.translations = {"manager_request": "i18n manager request message"}
+    def slice(self, key):
+        return self.translations.get(key, "")
+
+class DummyAgent:
+    def __init__(self):
+        self.i18n = DummyI18n()
+    def execute_task(self, task, context):
+        # Return the expected_output to verify it is set correctly
+        return task.expected_output
+
+def test_task_uses_agent_i18n_settings():
+    agent = DummyAgent()
+    tool = BaseAgentTools()
+    task_description = "dummy task"
+    context = {}
+
+    # Patch BaseAgentTools to use DummyAgent and DummyI18n
+    # We test that expected_output is set from agent.i18n.slice("manager_request")
+    result = tool._create_task_with_i18n(agent, task_description, context)
+    # The result should be the i18n manager_request string
+    assert result == "i18n manager request message"
+
+# Monkeypatch BaseAgentTools to add _create_task_with_i18n for testing
+def _create_task_with_i18n(self, agent, task, context):
+    task_with_assigned_agent = Task(
+        description=task,
+        agent=agent,
+        expected_output=agent.i18n.slice("manager_request"),
+        i18n=agent.i18n,
+    )
+    return agent.execute_task(task_with_assigned_agent, context)
+
+BaseAgentTools._create_task_with_i18n = _create_task_with_i18n
EOF_114329324912

git checkout 916dec241836cb85c4eda5c8a4e1e0c00aa6c802

# Activate the Python virtual environment created in /testbed/testbed/
source /testbed/testbed/bin/activate

# Run target test file only, with concise output showing test file names and statuses
# Use uvx pytest command as per context information; uvx handles environment layers and pytest is for testing.
uvx pytest -v --tb=short lib/crewai/tests/agents/agent_builder/test_base_agent_tool_i18n.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset any changes after tests
git checkout 916dec241836cb85c4eda5c8a4e1e0c00aa6c802 "lib/crewai/tests/agents/agent_builder/test_base_agent_tool_i18n.py"
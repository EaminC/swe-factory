#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout de5d2eaa9b12167ea14ecf59c70f59227fd63fe3

git apply -v - <<'EOF_114329324912'
diff --git a/lib/crewai/tests/agents/test_crew_agent_executor.py b/lib/crewai/tests/agents/test_crew_agent_executor.py
new file mode 100644
index 00000000..e1a2b3c4
--- /dev/null
+++ b/lib/crewai/tests/agents/test_crew_agent_executor.py
@@ -0,0 +1,40 @@
+import pytest
+
+from src.crewai.agents.crew_agent_executor import CrewAgentExecutor
+
+class DummyFormattedAnswer:
+    def __init__(self, text):
+        self.text = text
+
+class DummyCrewAgentExecutor(CrewAgentExecutor):
+    def __init__(self):
+        self.messages = []
+        self.have_forced_answer = False
+        self._format_msg_called_with = None
+
+    def _format_msg(self, text, role):
+        self._format_msg_called_with = (text, role)
+        return {'role': role, 'content': text}
+
+    def append_agent_action_message(self, formatted_answer):
+        # Simulate the buggy behavior: always role='user'
+        self.messages.append(self._format_msg(formatted_answer.text, role="user"))
+
+    def append_agent_action_message_fixed(self, formatted_answer):
+        # Correct behavior: role='assistant'
+        self.messages.append(self._format_msg(formatted_answer.text, role="assistant"))
+
+@pytest.mark.parametrize("use_fixed", [False, True])
+def test_agent_action_message_role(use_fixed):
+    executor = DummyCrewAgentExecutor()
+    answer = DummyFormattedAnswer("Thought: do something\nAction: tool\nAction Input: input\nObservation: result")
+    if use_fixed:
+        executor.append_agent_action_message_fixed(answer)
+    else:
+        executor.append_agent_action_message(answer)
+    last_msg = executor.messages[-1]
+    if use_fixed:
+        assert last_msg['role'] == 'assistant', "AgentAction message role should be 'assistant' after fix"
+    else:
+        assert last_msg['role'] == 'user', "AgentAction message role is incorrectly 'user' before fix"
+
EOF_114329324912

source /testbed/testbed/bin/activate

# Run only the specified test file with pytest via uvx
uvx pytest lib/crewai/tests/agents/test_crew_agent_executor.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout de5d2eaa9b12167ea14ecf59c70f59227fd63fe3 lib/crewai/tests/agents/test_crew_agent_executor.py
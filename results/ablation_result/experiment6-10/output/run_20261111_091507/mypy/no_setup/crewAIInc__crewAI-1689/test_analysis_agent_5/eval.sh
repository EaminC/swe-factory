#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 4bc23affe0e322f4c48be7ea4e5abb0e273569d6

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_result_as_answer.py b/tests/test_result_as_answer.py
new file mode 100644
index 0000000..e1a2b3c
--- /dev/null
+++ b/tests/test_result_as_answer.py
@@ -0,0 +1,69 @@
+import pytest
+from crewai.agents.crew_agent_executor import CrewAgentExecutor, ToolResult
+from crewai.agents.agent_builder.base_agent import BaseAgent
+from crewai.tools.base_tool import BaseTool
+from crewai.agents.crew_agent_executor import AgentAction, AgentFinish
+
+
+class DummyTool(BaseTool):
+    def __init__(self, name, result, result_as_answer):
+        super().__init__(name)
+        self._result = result
+        self._result_as_answer = result_as_answer
+
+    def run(self, input_text):
+        return self._result
+
+    def run_with_result_as_answer(self, input_text):
+        return ToolResult(result=self._result, result_as_answer=self._result_as_answer)
+
+
+class DummyAgent(BaseAgent):
+    def plan(self, prompt):
+        return AgentAction(tool_name="dummy", tool_input="input")
+
+
+def test_result_as_answer_short_circuit():
+    tool = DummyTool(name="dummy", result="42", result_as_answer=True)
+    agent = DummyAgent()
+    executor = CrewAgentExecutor(
+        agent=agent,
+        prompt={"input": "test"},
+        max_iter=3,
+        tools=[tool],
+        tools_names="dummy",
+        stop_words=[],
+        tools_description="dummy tool",
+        llm=None,
+        step_callback=None,
+    )
+    # Patch _execute_tool_and_check_finality to use our dummy tool method
+    def fake_execute_tool_and_check_finality(agent_action):
+        return ToolResult(result=tool._result, result_as_answer=tool._result_as_answer)
+    executor._execute_tool_and_check_finality = fake_execute_tool_and_check_finality
+
+    result = executor._invoke_loop()
+    assert isinstance(result, AgentFinish)
+    assert result.output == "42"
+
+def test_result_as_answer_false_continues():
+    tool = DummyTool(name="dummy", result="not final", result_as_answer=False)
+    agent = DummyAgent()
+    executor = CrewAgentExecutor(
+        agent=agent,
+        prompt={"input": "test"},
+        max_iter=1,
+        tools=[tool],
+        tools_names="dummy",
+        stop_words=[],
+        tools_description="dummy tool",
+        llm=None,
+        step_callback=None,
+    )
+    def fake_execute_tool_and_check_finality(agent_action):
+        return ToolResult(result=tool._result, result_as_answer=tool._result_as_answer)
+    executor._execute_tool_and_check_finality = fake_execute_tool_and_check_finality
+
+    result = executor._invoke_loop()
+    # Since max_iter=1 and no final answer, result should be None or not AgentFinish
+    assert not isinstance(result, AgentFinish)
EOF_114329324912

# Activate the python virtual environment
source /testbed/.venv/bin/activate

# Ensure pytest and related test dependencies are installed
pip install pytest pytest-vcr pytest-asyncio pytest-subprocess

# Run tests on the specified test file only
pytest -v tests/test_result_as_answer.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Since tests/test_result_as_answer.py does not exist at this commit or is untracked,
# skip attempting to reset it to avoid git errors.
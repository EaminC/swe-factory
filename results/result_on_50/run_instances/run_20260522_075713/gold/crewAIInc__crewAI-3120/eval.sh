#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset the target test file to the committed version before applying patch
git checkout eec1262d4fb9dc3ad700d18585a36ae30c860562 "tests/test_lite_agent.py"

# Apply the test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_lite_agent.py b/tests/test_lite_agent.py
--- a/tests/test_lite_agent.py
+++ b/tests/test_lite_agent.py
@@ -12,6 +12,8 @@
 from crewai.utilities.events import crewai_event_bus
 from crewai.utilities.events.agent_events import LiteAgentExecutionStartedEvent
 from crewai.utilities.events.tool_usage_events import ToolUsageStartedEvent
+from crewai.llms.base_llm import BaseLLM
+from unittest.mock import patch
 
 
 # A simple test tool
@@ -418,3 +420,76 @@ class Player(BaseModel):
     result = agent.kickoff(messages="Top 10 best players in the world?")
 
     assert result.pydantic == Player(name="Lionel Messi", country="Argentina")
+
+def test_lite_agent_with_custom_llm_and_guardrails():
+    """Test that CustomLLM (inheriting from BaseLLM) works with guardrails."""
+    class CustomLLM(BaseLLM):
+        def __init__(self, response: str = "Custom response"):
+            super().__init__(model="custom-model")
+            self.response = response
+            self.call_count = 0
+
+        def call(self, messages, tools=None, callbacks=None, available_functions=None, from_task=None, from_agent=None) -> str:
+            self.call_count += 1
+
+            if "valid" in str(messages) and "feedback" in str(messages):
+                return '{"valid": true, "feedback": null}'
+
+            if "Thought:" in str(messages):
+                return f"Thought: I will analyze soccer players\nFinal Answer: {self.response}"
+
+            return self.response
+
+        def supports_function_calling(self) -> bool:
+            return False
+
+        def supports_stop_words(self) -> bool:
+            return False
+
+        def get_context_window_size(self) -> int:
+            return 4096
+
+    custom_llm = CustomLLM(response="Brazilian soccer players are the best!")
+
+    agent = LiteAgent(
+        role="Sports Analyst",
+        goal="Analyze soccer players",
+        backstory="You analyze soccer players and their performance.",
+        llm=custom_llm,
+        guardrail="Only include Brazilian players"
+    )
+
+    result = agent.kickoff("Tell me about the best soccer players")
+
+    assert custom_llm.call_count > 0
+    assert "Brazilian" in result.raw
+
+    custom_llm2 = CustomLLM(response="Original response")
+
+    def test_guardrail(output):
+        return (True, "Modified by guardrail")
+
+    agent2 = LiteAgent(
+        role="Test Agent",
+        goal="Test goal",
+        backstory="Test backstory",
+        llm=custom_llm2,
+        guardrail=test_guardrail
+    )
+
+    result2 = agent2.kickoff("Test message")
+    assert result2.raw == "Modified by guardrail"
+
+
+@pytest.mark.vcr(filter_headers=["authorization"])
+def test_lite_agent_with_invalid_llm():
+    """Test that LiteAgent raises proper error when create_llm returns None."""
+    with patch('crewai.lite_agent.create_llm', return_value=None):
+        with pytest.raises(ValueError) as exc_info:
+            LiteAgent(
+                role="Test Agent",
+                goal="Test goal", 
+                backstory="Test backstory",
+                llm="invalid-model"
+            )
+        assert "Expected LLM instance of type BaseLLM" in str(exc_info.value)
\ No newline at end of file
EOF_114329324912

# Reset the target test file again to ensure clean state after patch application
git checkout eec1262d4fb9dc3ad700d18585a36ae30c860562 "tests/test_lite_agent.py"

# Activate the virtual environment
source /testbed/testbed_venv/bin/activate

# Export required environment variables for authentication
export OPENAI_API_KEY="${OPENAI_API_KEY:-}"
export SERPER_API_KEY="${SERPER_API_KEY:-}"
export OTEL_SDK_DISABLED="${OTEL_SDK_DISABLED:-true}"

# Execute the specified test file with required pytest options from context
PYTHONPATH=.pytest_sqlite_override uv run pytest tests/test_lite_agent.py --block-network --timeout=30 -vv --maxfail=3
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"
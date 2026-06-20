#!/bin/bash
set -uxo pipefail
cd /testbed

# Activate the virtual environment created by UV
source /testbed/.venv/bin/activate

# Restore the target test file to its original state before applying patch
# Use the correct path relative to the repository root
git checkout 528d81226361be0f87c9e077ed0d3eb28243120f -- "lib/crewai/tests/agents/test_a2a_trust_completion_status.py"

# Apply the test patch (if provided)
# The patch content will be inserted programmatically
git apply -v - <<'EOF_114329324912'
diff --git a/lib/crewai/tests/agents/test_a2a_trust_completion_status.py b/lib/crewai/tests/agents/test_a2a_trust_completion_status.py
new file mode 100644
--- /dev/null
+++ b/lib/crewai/tests/agents/test_a2a_trust_completion_status.py
@@ -0,0 +1,147 @@
+"""Test trust_remote_completion_status flag in A2A wrapper."""
+
+from unittest.mock import MagicMock, patch
+
+import pytest
+
+from crewai.a2a.config import A2AConfig
+
+try:
+    from a2a.types import Message, Role
+
+    A2A_SDK_INSTALLED = True
+except ImportError:
+    A2A_SDK_INSTALLED = False
+
+
+@pytest.mark.skipif(not A2A_SDK_INSTALLED, reason="Requires a2a-sdk to be installed")
+def test_trust_remote_completion_status_true_returns_directly():
+    """When trust_remote_completion_status=True and A2A returns completed, return result directly."""
+    from crewai.a2a.wrapper import _delegate_to_a2a
+    from crewai.a2a.types import AgentResponseProtocol
+    from crewai import Agent, Task
+
+    a2a_config = A2AConfig(
+        endpoint="http://test-endpoint.com",
+        trust_remote_completion_status=True,
+    )
+
+    agent = Agent(
+        role="test manager",
+        goal="coordinate",
+        backstory="test",
+        a2a=a2a_config,
+    )
+
+    task = Task(description="test", expected_output="test", agent=agent)
+
+    class MockResponse:
+        is_a2a = True
+        message = "Please help"
+        a2a_ids = ["http://test-endpoint.com/"]
+
+    with (
+        patch("crewai.a2a.wrapper.execute_a2a_delegation") as mock_execute,
+        patch("crewai.a2a.wrapper._fetch_agent_cards_concurrently") as mock_fetch,
+    ):
+        mock_card = MagicMock()
+        mock_card.name = "Test"
+        mock_fetch.return_value = ({"http://test-endpoint.com/": mock_card}, {})
+
+        # A2A returns completed
+        mock_execute.return_value = {
+            "status": "completed",
+            "result": "Done by remote",
+            "history": [],
+        }
+
+        # This should return directly without checking LLM response
+        result = _delegate_to_a2a(
+            self=agent,
+            agent_response=MockResponse(),
+            task=task,
+            original_fn=lambda *args, **kwargs: "fallback",
+            context=None,
+            tools=None,
+            agent_cards={"http://test-endpoint.com/": mock_card},
+            original_task_description="test",
+        )
+
+        assert result == "Done by remote"
+        assert mock_execute.call_count == 1
+
+
+@pytest.mark.skipif(not A2A_SDK_INSTALLED, reason="Requires a2a-sdk to be installed")
+def test_trust_remote_completion_status_false_continues_conversation():
+    """When trust_remote_completion_status=False and A2A returns completed, ask server agent."""
+    from crewai.a2a.wrapper import _delegate_to_a2a
+    from crewai import Agent, Task
+
+    a2a_config = A2AConfig(
+        endpoint="http://test-endpoint.com",
+        trust_remote_completion_status=False,
+    )
+
+    agent = Agent(
+        role="test manager",
+        goal="coordinate",
+        backstory="test",
+        a2a=a2a_config,
+    )
+
+    task = Task(description="test", expected_output="test", agent=agent)
+
+    class MockResponse:
+        is_a2a = True
+        message = "Please help"
+        a2a_ids = ["http://test-endpoint.com/"]
+
+    call_count = 0
+
+    def mock_original_fn(self, task, context, tools):
+        nonlocal call_count
+        call_count += 1
+        if call_count == 1:
+            # Server decides to finish
+            return '{"is_a2a": false, "message": "Server final answer", "a2a_ids": []}'
+        return "unexpected"
+
+    with (
+        patch("crewai.a2a.wrapper.execute_a2a_delegation") as mock_execute,
+        patch("crewai.a2a.wrapper._fetch_agent_cards_concurrently") as mock_fetch,
+    ):
+        mock_card = MagicMock()
+        mock_card.name = "Test"
+        mock_fetch.return_value = ({"http://test-endpoint.com/": mock_card}, {})
+
+        # A2A returns completed
+        mock_execute.return_value = {
+            "status": "completed",
+            "result": "Done by remote",
+            "history": [],
+        }
+
+        result = _delegate_to_a2a(
+            self=agent,
+            agent_response=MockResponse(),
+            task=task,
+            original_fn=mock_original_fn,
+            context=None,
+            tools=None,
+            agent_cards={"http://test-endpoint.com/": mock_card},
+            original_task_description="test",
+        )
+
+        # Should call original_fn to get server response
+        assert call_count >= 1
+        assert result == "Server final answer"
+
+
+@pytest.mark.skipif(not A2A_SDK_INSTALLED, reason="Requires a2a-sdk to be installed")
+def test_default_trust_remote_completion_status_is_false():
+    """Verify that default value of trust_remote_completion_status is False."""
+    a2a_config = A2AConfig(
+        endpoint="http://test-endpoint.com",
+    )
+
+    assert a2a_config.trust_remote_completion_status is False
\ No newline at end of file
EOF_114329324912

# Run only the specified test file with the same flags as in CI
# Change to lib/crewai directory first (as done in CI workflow)
cd lib/crewai
# Use correct relative path from within lib/crewai directory
uv run pytest tests/agents/test_a2a_trust_completion_status.py --block-network --timeout=30 -vv --durations=10 -n auto --maxfail=3
rc=$?            # Required, save exit code

echo "OMNIGRIL_EXIT_CODE=$rc" # Required, echo test status

# Restore the target test file to original state after test execution
# Return to repository root first
cd /testbed
git checkout 528d81226361be0f87c9e077ed0d3eb28243120f -- "lib/crewai/tests/agents/test_a2a_trust_completion_status.py"
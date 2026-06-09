#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 73f328860b4a477a6d3736e646783d7493841cb4 "tests/crew_test.py" "tests/test_manager_llm_delegation.py"

# Apply the test patch to update target tests
git apply -v - <<'EOF_114329324912'
diff --git a/tests/crew_test.py b/tests/crew_test.py
--- a/tests/crew_test.py
+++ b/tests/crew_test.py
@@ -391,6 +391,71 @@ def test_manager_agent_delegating_to_all_agents():
     )
 
 
+@pytest.mark.vcr(filter_headers=["authorization"])
+def test_manager_agent_delegates_with_varied_role_cases():
+    """
+    Test that the manager agent can delegate to agents regardless of case or whitespace variations in role names.
+    This test verifies the fix for issue #1503 where role matching was too strict.
+    """
+    # Create agents with varied case and whitespace in roles
+    researcher_spaced = Agent(
+        role=" Researcher ",  # Extra spaces
+        goal="Research with spaces in role",
+        backstory="A researcher with spaces in role name",
+        allow_delegation=False,
+    )
+    
+    writer_caps = Agent(
+        role="SENIOR WRITER",  # All caps
+        goal="Write with caps in role",
+        backstory="A writer with caps in role name",
+        allow_delegation=False,
+    )
+
+    task = Task(
+        description="Research and write about AI. The researcher should do the research, and the writer should write it up.",
+        expected_output="A well-researched article about AI.",
+        agent=researcher_spaced,  # Assign to researcher with spaces
+    )
+
+    crew = Crew(
+        agents=[researcher_spaced, writer_caps],
+        process=Process.hierarchical,
+        manager_llm="gpt-4o",
+        tasks=[task],
+    )
+
+    mock_task_output = TaskOutput(
+        description="Mock description",
+        raw="mocked output",
+        agent="mocked agent"
+    )
+    task.output = mock_task_output
+
+    with patch.object(Task, 'execute_sync', return_value=mock_task_output) as mock_execute_sync:
+        crew.kickoff()
+
+        # Verify execute_sync was called once
+        mock_execute_sync.assert_called_once()
+
+        # Get the tools argument from the call
+        _, kwargs = mock_execute_sync.call_args
+        tools = kwargs['tools']
+
+        # Verify the delegation tools were passed correctly and can handle case/whitespace variations
+        assert len(tools) == 2
+        
+        # Check delegation tool descriptions (should work despite case/whitespace differences)
+        delegation_tool = tools[0]
+        question_tool = tools[1]
+        
+        assert "Delegate a specific task to one of the following coworkers:" in delegation_tool.description
+        assert " Researcher " in delegation_tool.description or "SENIOR WRITER" in delegation_tool.description
+        
+        assert "Ask a specific question to one of the following coworkers:" in question_tool.description
+        assert " Researcher " in question_tool.description or "SENIOR WRITER" in question_tool.description
+
+
 @pytest.mark.vcr(filter_headers=["authorization"])
 def test_crew_with_delegating_agents():
     tasks = [
diff --git a/tests/test_manager_llm_delegation.py b/tests/test_manager_llm_delegation.py
new file mode 100644
--- /dev/null
+++ b/tests/test_manager_llm_delegation.py
@@ -0,0 +1,55 @@
+from unittest.mock import MagicMock
+
+import pytest
+
+from crewai import Agent, Task
+from crewai.tools.agent_tools.base_agent_tools import BaseAgentTool
+
+
+class TestAgentTool(BaseAgentTool):
+    """Concrete implementation of BaseAgentTool for testing."""
+    def _run(self, *args, **kwargs):
+        """Implement required _run method."""
+        return "Test response"
+
+@pytest.mark.parametrize("role_name,should_match", [
+    ('Futel Official Infopoint', True),                    # exact match
+    ('  "Futel Official Infopoint"  ', True),             # extra quotes and spaces
+    ('Futel Official Infopoint\n', True),                 # trailing newline
+    ('"Futel Official Infopoint"', True),                 # embedded quotes
+    (' FUTEL\nOFFICIAL   INFOPOINT ', True),             # multiple whitespace and newline
+    ('futel official infopoint', True),                   # lowercase
+    ('FUTEL OFFICIAL INFOPOINT', True),                   # uppercase
+    ('Non Existent Agent', False),                        # non-existent agent
+    (None, False),                                        # None agent name
+])
+def test_agent_tool_role_matching(role_name, should_match):
+    """Test that agent tools can match roles regardless of case, whitespace, and special characters."""
+    # Create test agent
+    test_agent = Agent(
+        role='Futel Official Infopoint',
+        goal='Answer questions about Futel',
+        backstory='Futel Football Club info',
+        allow_delegation=False
+    )
+
+    # Create test agent tool
+    agent_tool = TestAgentTool(
+        name="test_tool",
+        description="Test tool",
+        agents=[test_agent]
+    )
+
+    # Test role matching
+    result = agent_tool._execute(
+        agent_name=role_name,
+        task='Test task',
+        context=None
+    )
+
+    if should_match:
+        assert "coworker mentioned not found" not in result.lower(), \
+            f"Should find agent with role name: {role_name}"
+    else:
+        assert "coworker mentioned not found" in result.lower(), \
+            f"Should not find agent with role name: {role_name}"
EOF_114329324912

# Activate virtual environment and run only the specified test files with pytest via uv
source /testbed/testbed_venv/bin/activate

uv run pytest -rA --tb=short --disable-warnings tests/crew_test.py tests/test_manager_llm_delegation.py
rc=$?            #Required, save exit code

echo "OMNIGRIL_EXIT_CODE=$rc" #Required, echo test status

# Cleanup: revert test file changes to original state
git checkout 73f328860b4a477a6d3736e646783d7493841cb4 "tests/crew_test.py" "tests/test_manager_llm_delegation.py"
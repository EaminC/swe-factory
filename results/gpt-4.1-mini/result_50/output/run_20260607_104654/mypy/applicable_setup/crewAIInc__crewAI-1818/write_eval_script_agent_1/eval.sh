#!/bin/bash
set -uxo pipefail

cd /testbed

# Checkout target test files to reset any changes
git checkout a548463faebd22aa3167a13ad417b4ab89776478 "tests/utilities/test_planning_handler.py" "tests/utilities/test_knowledge_planning.py"

# Apply test patch (replace [CONTENT OF TEST PATCH] with actual patch content at runtime)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/utilities/test_knowledge_planning.py b/tests/utilities/test_knowledge_planning.py
new file mode 100644
--- /dev/null
+++ b/tests/utilities/test_knowledge_planning.py
@@ -0,0 +1,84 @@
+"""
+Tests for verifying the integration of knowledge sources in the planning process.
+This module ensures that agent knowledge is properly included during task planning.
+"""
+
+from unittest.mock import patch
+
+import pytest
+
+from crewai.agent import Agent
+from crewai.knowledge.source.string_knowledge_source import StringKnowledgeSource
+from crewai.task import Task
+from crewai.utilities.planning_handler import CrewPlanner
+
+
+@pytest.fixture
+def mock_knowledge_source():
+    """
+    Create a mock knowledge source with test content.
+    Returns:
+        StringKnowledgeSource:
+            A knowledge source containing AI-related test content
+    """
+    content = """
+    Important context about AI:
+    1. AI systems use machine learning algorithms
+    2. Neural networks are a key component
+    3. Training data is essential for good performance
+    """
+    return StringKnowledgeSource(content=content)
+
+@patch('crewai.knowledge.storage.knowledge_storage.chromadb')
+def test_knowledge_included_in_planning(mock_chroma):
+    """Test that verifies knowledge sources are properly included in planning."""
+    # Mock ChromaDB collection
+    mock_collection = mock_chroma.return_value.get_or_create_collection.return_value
+    mock_collection.add.return_value = None
+    
+    # Create an agent with knowledge
+    agent = Agent(
+        role="AI Researcher",
+        goal="Research and explain AI concepts",
+        backstory="Expert in artificial intelligence",
+        knowledge_sources=[
+            StringKnowledgeSource(
+                content="AI systems require careful training and validation."
+            )
+        ]
+    )
+
+    # Create a task for the agent
+    task = Task(
+        description="Explain the basics of AI systems",
+        expected_output="A clear explanation of AI fundamentals",
+        agent=agent
+    )
+
+    # Create a crew planner
+    planner = CrewPlanner([task], None)
+
+    # Get the task summary
+    task_summary = planner._create_tasks_summary()
+
+    # Verify that knowledge is included in planning when present
+    assert "AI systems require careful training" in task_summary, \
+        "Knowledge content should be present in task summary when knowledge exists"
+    assert '"agent_knowledge"' in task_summary, \
+        "agent_knowledge field should be present in task summary when knowledge exists"
+
+    # Verify that knowledge is properly formatted
+    assert isinstance(task.agent.knowledge_sources, list), \
+        "Knowledge sources should be stored in a list"
+    assert len(task.agent.knowledge_sources) > 0, \
+        "At least one knowledge source should be present"
+    assert task.agent.knowledge_sources[0].content in task_summary, \
+        "Knowledge source content should be included in task summary"
+
+    # Verify that other expected components are still present
+    assert task.description in task_summary, \
+        "Task description should be present in task summary"
+    assert task.expected_output in task_summary, \
+        "Expected output should be present in task summary"
+    assert agent.role in task_summary, \
+        "Agent role should be present in task summary"
diff --git a/tests/utilities/test_planning_handler.py b/tests/utilities/test_planning_handler.py
--- a/tests/utilities/test_planning_handler.py
+++ b/tests/utilities/test_planning_handler.py
@@ -1,10 +1,14 @@
-from unittest.mock import patch
+from typing import Optional
+from unittest.mock import MagicMock, patch
 
 import pytest
+from pydantic import BaseModel
 
 from crewai.agent import Agent
+from crewai.knowledge.source.string_knowledge_source import StringKnowledgeSource
 from crewai.task import Task
 from crewai.tasks.task_output import TaskOutput
+from crewai.tools.base_tool import BaseTool
 from crewai.utilities.planning_handler import (
     CrewPlanner,
     PlannerTaskPydanticOutput,
@@ -92,7 +96,72 @@ def test_create_tasks_summary(self, crew_planner):
         tasks_summary = crew_planner._create_tasks_summary()
         assert isinstance(tasks_summary, str)
         assert tasks_summary.startswith("\n                Task Number 1 - Task 1")
-        assert tasks_summary.endswith('"agent_tools": []\n                ')
+        assert '"agent_tools": "agent has no tools"' in tasks_summary
+        # Knowledge field should not be present when empty
+        assert '"agent_knowledge"' not in tasks_summary
+
+    @patch('crewai.knowledge.storage.knowledge_storage.chromadb')
+    def test_create_tasks_summary_with_knowledge_and_tools(self, mock_chroma):
+        """Test task summary generation with both knowledge and tools present."""
+        # Mock ChromaDB collection
+        mock_collection = mock_chroma.return_value.get_or_create_collection.return_value
+        mock_collection.add.return_value = None
+
+        # Create mock tools with proper string descriptions and structured tool support
+        class MockTool(BaseTool):
+            name: str
+            description: str
+
+            def __init__(self, name: str, description: str):
+                tool_data = {"name": name, "description": description}
+                super().__init__(**tool_data)
+            
+            def __str__(self):
+                return self.name
+            
+            def __repr__(self):
+                return self.name
+            
+            def to_structured_tool(self):
+                return self
+
+            def _run(self, *args, **kwargs):
+                pass
+
+            def _generate_description(self) -> str:
+                """Override _generate_description to avoid args_schema handling."""
+                return self.description
+
+        tool1 = MockTool("tool1", "Tool 1 description")
+        tool2 = MockTool("tool2", "Tool 2 description")
+
+        # Create a task with knowledge and tools
+        task = Task(
+            description="Task with knowledge and tools",
+            expected_output="Expected output",
+            agent=Agent(
+                role="Test Agent",
+                goal="Test Goal",
+                backstory="Test Backstory",
+                tools=[tool1, tool2],
+                knowledge_sources=[
+                    StringKnowledgeSource(content="Test knowledge content")
+                ]
+            )
+        )
+        
+        # Create planner with the new task
+        planner = CrewPlanner([task], None)
+        tasks_summary = planner._create_tasks_summary()
+        
+        # Verify task summary content
+        assert isinstance(tasks_summary, str)
+        assert task.description in tasks_summary
+        assert task.expected_output in tasks_summary
+        assert '"agent_tools": [tool1, tool2]' in tasks_summary
+        assert '"agent_knowledge": "[\\"Test knowledge content\\"]"' in tasks_summary
+        assert task.agent.role in tasks_summary
+        assert task.agent.goal in tasks_summary
 
     def test_handle_crew_planning_different_llm(self, crew_planner_different_llm):
         with patch.object(Task, "execute_sync") as execute:
EOF_114329324912

# Activate the UV environment (virtual env is on PATH according to Dockerfile, just ensure)
# We are already in the correct environment with PATH set in Dockerfile,
# so no explicit activation required here.

# Run only the specified test files in one pytest invocation via uv run
uv run pytest tests/utilities/test_planning_handler.py tests/utilities/test_knowledge_planning.py --tb=short -rA --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test files to original state after testing
git checkout a548463faebd22aa3167a13ad417b4ab89776478 "tests/utilities/test_planning_handler.py" "tests/utilities/test_knowledge_planning.py"
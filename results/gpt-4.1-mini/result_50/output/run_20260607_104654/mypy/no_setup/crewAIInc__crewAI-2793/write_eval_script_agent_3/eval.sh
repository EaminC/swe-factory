#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset the target test file to the committed state to ensure a clean state
git checkout fed397f74590a3f1c3be3bfca96e4967fe38a3e1 "tests/crew_test.py"

# Apply test patch (placeholder content to be replaced)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/crew_test.py b/tests/crew_test.py
--- a/tests/crew_test.py
+++ b/tests/crew_test.py
@@ -2,22 +2,18 @@
 
 import hashlib
 import json
-import os
-import tempfile
 from concurrent.futures import Future
 from unittest import mock
-from unittest.mock import MagicMock, patch
+from unittest.mock import ANY, MagicMock, patch
 
 import pydantic_core
 import pytest
 
 from crewai.agent import Agent
 from crewai.agents import CacheHandler
-from crewai.agents.cache import CacheHandler
-from crewai.agents.crew_agent_executor import CrewAgentExecutor
 from crewai.crew import Crew
 from crewai.crews.crew_output import CrewOutput
-from crewai.flow import Flow, listen, start
+from crewai.flow import Flow, start
 from crewai.knowledge.source.string_knowledge_source import StringKnowledgeSource
 from crewai.llm import LLM
 from crewai.memory.contextual.contextual_memory import ContextualMemory
@@ -3141,6 +3137,30 @@ def test_replay_with_context():
         assert crew.tasks[1].context[0].output.raw == "context raw output"
 
 
+def test_replay_with_context_set_to_nullable():
+    agent = Agent(role="test_agent", backstory="Test Description", goal="Test Goal")
+    task1 = Task(
+        description="Context Task", expected_output="Say Task Output", agent=agent
+    )
+    task2 = Task(
+        description="Test Task", expected_output="Say Hi", agent=agent, context=[]
+    )
+    task3 = Task(
+        description="Test Task 3", expected_output="Say Hi", agent=agent, context=None
+    )
+
+    crew = Crew(agents=[agent], tasks=[task1, task2, task3], process=Process.sequential)
+    with patch("crewai.task.Task.execute_sync") as mock_execute_task:
+        mock_execute_task.return_value = TaskOutput(
+            description="Test Task Output",
+            raw="test raw output",
+            agent="test_agent",
+        )
+        crew.kickoff()
+
+    mock_execute_task.assert_called_with(agent=ANY, context="", tools=ANY)
+
+
 @pytest.mark.vcr(filter_headers=["authorization"])
 def test_replay_with_invalid_task_id():
     agent = Agent(role="test_agent", backstory="Test Description", goal="Test Goal")
EOF_114329324912

# Export required API keys (set dummy keys if not provided externally)
export OPENAI_API_KEY="${OPENAI_API_KEY:-dummy_openai_api_key}"
export SERPER_API_KEY="${SERPER_API_KEY:-dummy_serper_api_key}"

# Activate the virtual environment installed by uv within /testbed/.venv
source /testbed/.venv/bin/activate

# Run only the specified test file with detailed and concise output
# Use pytest with verbose and short traceback, disable warnings for cleaner output
uv run pytest -rA --tb=short --disable-warnings tests/crew_test.py

rc=$?  # Capture the exit code immediately after test run

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to the committed state after testing (clean up)
git checkout fed397f74590a3f1c3be3bfca96e4967fe38a3e1 "tests/crew_test.py"
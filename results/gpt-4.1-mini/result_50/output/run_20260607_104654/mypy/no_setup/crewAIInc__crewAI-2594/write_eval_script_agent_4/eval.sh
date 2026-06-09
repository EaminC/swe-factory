#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset the target test file to the committed state before applying patch
git checkout 6a1eb10830ac6ab3602bbc4ee07d565bd9eab46f tests/crew_test.py

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/crew_test.py b/tests/crew_test.py
--- a/tests/crew_test.py
+++ b/tests/crew_test.py
@@ -3,6 +3,7 @@
 import hashlib
 import json
 import os
+import tempfile
 from concurrent.futures import Future
 from unittest import mock
 from unittest.mock import MagicMock, patch
@@ -19,6 +20,7 @@
 from crewai.knowledge.source.string_knowledge_source import StringKnowledgeSource
 from crewai.llm import LLM
 from crewai.memory.contextual.contextual_memory import ContextualMemory
+from crewai.memory.short_term.short_term_memory import ShortTermMemory
 from crewai.process import Process
 from crewai.task import Task
 from crewai.tasks.conditional_task import ConditionalTask
@@ -4116,6 +4118,54 @@ def test_crew_kickoff_for_each_works_with_manager_agent_copy():
     assert crew_copy.manager_agent.id != crew.manager_agent.id
     assert crew_copy.manager_agent.role == crew.manager_agent.role
     assert crew_copy.manager_agent.goal == crew.manager_agent.goal
-    assert crew_copy.manager_agent.backstory == crew.manager_agent.backstory
-    assert isinstance(crew_copy.manager_agent.agent_executor, CrewAgentExecutor)
-    assert isinstance(crew_copy.manager_agent.cache_handler, CacheHandler)
+
+def test_crew_copy_with_memory():
+    """Test that copying a crew with memory enabled does not raise validation errors and copies memory correctly."""
+    agent = Agent(role="Test Agent", goal="Test Goal", backstory="Test Backstory")
+    task = Task(description="Test Task", expected_output="Test Output", agent=agent)
+    crew = Crew(agents=[agent], tasks=[task], memory=True)
+
+    original_short_term_id = id(crew._short_term_memory) if crew._short_term_memory else None
+    original_long_term_id = id(crew._long_term_memory) if crew._long_term_memory else None
+    original_entity_id = id(crew._entity_memory) if crew._entity_memory else None
+    original_external_id = id(crew._external_memory) if crew._external_memory else None
+    original_user_id = id(crew._user_memory) if crew._user_memory else None
+
+
+    try:
+        crew_copy = crew.copy()
+
+        assert hasattr(crew_copy, "_short_term_memory"), "Copied crew should have _short_term_memory"
+        assert crew_copy._short_term_memory is not None, "Copied _short_term_memory should not be None"
+        assert id(crew_copy._short_term_memory) != original_short_term_id, "Copied _short_term_memory should be a new object"
+
+        assert hasattr(crew_copy, "_long_term_memory"), "Copied crew should have _long_term_memory"
+        assert crew_copy._long_term_memory is not None, "Copied _long_term_memory should not be None"
+        assert id(crew_copy._long_term_memory) != original_long_term_id, "Copied _long_term_memory should be a new object"
+
+        assert hasattr(crew_copy, "_entity_memory"), "Copied crew should have _entity_memory"
+        assert crew_copy._entity_memory is not None, "Copied _entity_memory should not be None"
+        assert id(crew_copy._entity_memory) != original_entity_id, "Copied _entity_memory should be a new object"
+
+        if original_external_id:
+             assert hasattr(crew_copy, "_external_memory"), "Copied crew should have _external_memory"
+             assert crew_copy._external_memory is not None, "Copied _external_memory should not be None"
+             assert id(crew_copy._external_memory) != original_external_id, "Copied _external_memory should be a new object"
+        else:
+             assert not hasattr(crew_copy, "_external_memory") or crew_copy._external_memory is None, "Copied _external_memory should be None if not originally present"
+
+        if original_user_id:
+             assert hasattr(crew_copy, "_user_memory"), "Copied crew should have _user_memory"
+             assert crew_copy._user_memory is not None, "Copied _user_memory should not be None"
+             assert id(crew_copy._user_memory) != original_user_id, "Copied _user_memory should be a new object"
+        else:
+             assert not hasattr(crew_copy, "_user_memory") or crew_copy._user_memory is None, "Copied _user_memory should be None if not originally present"
+
+
+    except pydantic_core.ValidationError as e:
+         if "Input should be an instance of" in str(e) and ("Memory" in str(e)):
+              pytest.fail(f"Copying with memory raised Pydantic ValidationError, likely due to incorrect memory copy: {e}")
+         else:
+              raise e # Re-raise other validation errors
+    except Exception as e:
+        pytest.fail(f"Copying crew raised an unexpected exception: {e}")
EOF_114329324912

# Export environment variables for API keys, expect these to be set in the container runtime environment
export OPENAI_API_KEY="${OPENAI_API_KEY:?Environment variable OPENAI_API_KEY must be set}"
export SERPER_API_KEY="${SERPER_API_KEY:?Environment variable SERPER_API_KEY must be set}"

# Activate the correct virtual environment and run the specified test file using uv run pytest
source /testbed/.venv/bin/activate
uv run pytest -rA --tb=short --disable-warnings tests/crew_test.py
rc=$?

# Echo exit code for evaluation
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file to committed state after test run
git checkout 6a1eb10830ac6ab3602bbc4ee07d565bd9eab46f tests/crew_test.py
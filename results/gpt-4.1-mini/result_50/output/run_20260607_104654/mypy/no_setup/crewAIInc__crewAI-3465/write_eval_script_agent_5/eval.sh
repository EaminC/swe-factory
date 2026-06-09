#!/bin/bash
set -uxo pipefail

cd /testbed

# Only checkout the existing test file to avoid pathspec errors
git checkout 1dc4f2e8977eb68b54dc3184a9548dfe10e57f3e "tests/test_project.py"

# Apply test patch (replace [CONTENT OF TEST PATCH] with actual patch content at runtime)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_project.py b/tests/test_project.py
--- a/tests/test_project.py
+++ b/tests/test_project.py
@@ -1,5 +1,6 @@
-from typing import List
+from typing import Any, ClassVar
 from unittest.mock import Mock, patch
+
 import pytest
 
 from crewai.agent import Agent
@@ -44,8 +45,8 @@ class InternalCrew:
     agents_config = "config/agents.yaml"
     tasks_config = "config/tasks.yaml"
 
-    agents: List[BaseAgent]
-    tasks: List[Task]
+    agents: list[BaseAgent]
+    tasks: list[Task]
 
     @llm
     def local_llm(self):
@@ -89,7 +90,8 @@ def crew(self):
 
 @CrewBase
 class InternalCrewWithMCP(InternalCrew):
-    mcp_server_params = {"host": "localhost", "port": 8000}
+    mcp_server_params: ClassVar[dict[str, Any]] = {"host": "localhost", "port": 8000}
+    mcp_connect_timeout = 120
 
     @agent
     def reporting_analyst(self):
@@ -200,8 +202,8 @@ def test_before_kickoff_with_none_input():
 def test_multiple_before_after_kickoff():
     @CrewBase
     class MultipleHooksCrew:
-        agents: List[BaseAgent]
-        tasks: List[Task]
+        agents: list[BaseAgent]
+        tasks: list[Task]
 
         agents_config = "config/agents.yaml"
         tasks_config = "config/tasks.yaml"
@@ -284,4 +286,7 @@ def test_internal_crew_with_mcp():
         assert crew.reporting_analyst().tools == [simple_tool, another_simple_tool]
         assert crew.researcher().tools == [simple_tool]
 
-    adapter_mock.assert_called_once_with({"host": "localhost", "port": 8000})
+    adapter_mock.assert_called_once_with(
+        {"host": "localhost", "port": 8000},
+        connect_timeout=120
+    )
EOF_114329324912

# Export required environment variables for the tests to pass
export OPENAI_API_KEY="${OPENAI_API_KEY:-}"
export SERPER_API_KEY="${SERPER_API_KEY:-}"
export OTEL_SDK_DISABLED="${OTEL_SDK_DISABLED:-true}"

# Activate the Python virtual environment from the correct path
source /testbed/.venv/bin/activate

# Run only the specified existing test file with uv run pytest and concise output reporting
uv run pytest tests/test_project.py --tb=short -rA --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset modified test files to original state after testing
git checkout 1dc4f2e8977eb68b54dc3184a9548dfe10e57f3e "tests/test_project.py"
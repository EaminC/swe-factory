#!/bin/bash
set -uxo pipefail
cd /testbed

# Reset the test file to the committed state before applying patch
git checkout 1dc4f2e8977eb68b54dc3184a9548dfe10e57f3e tests/test_project.py

# Apply test patch
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

# Activate the correct virtual environment and run the specified test file using uv run pytest
source /testbed/.venv/bin/activate

# Confirm installation of embedchain package, install if missing
if ! python -c "import embedchain" &> /dev/null; then
    echo "embedchain package missing, installing..."
    pip install embedchain || (echo "Failed to install embedchain" >&2; exit 1)
fi

uv run pytest -rA --tb=short --disable-warnings tests/test_project.py
rc=$?

# Echo exit code for evaluation
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file to committed state after test run
git checkout 1dc4f2e8977eb68b54dc3184a9548dfe10e57f3e tests/test_project.py
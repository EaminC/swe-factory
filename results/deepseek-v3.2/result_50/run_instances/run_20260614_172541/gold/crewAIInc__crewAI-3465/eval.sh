#!/bin/bash
set -uxo pipefail

# Activate the UV virtual environment
source /testbed/.venv/bin/activate

# Debug: Verify Python version and environment
echo "=== Environment Verification ==="
python --version
echo "Python executable: $(which python)"
echo "UV version: $(uv --version)"
echo "Installed packages (before uninstall):"
uv pip list | grep -E "^(crewai|pytest|pytest-|litellm|onnxruntime|json-repair|portalocker)" || true
echo "=== End Environment Verification ==="

# Navigate to the repository root
cd /testbed

# Uninstall pytest-vcr to resolve conflict with pytest-recording
# UV's pip uninstall doesn't accept -y flag, so we pipe 'y' to confirm
echo "=== Uninstalling pytest-vcr ==="
echo 'y' | uv pip uninstall pytest-vcr

echo "=== Installed packages (after uninstall) ==="
uv pip list | grep -E "^(pytest-|crewai)" || true

# Ensure the target test file is at the correct commit state
git checkout 1dc4f2e8977eb68b54dc3184a9548dfe10e57f3e "tests/test_project.py"

# Apply the test patch (placeholder will be replaced during execution)
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

# Run the specified test file using pytest with UV
# Use uv run to ensure proper environment isolation and dependency resolution
# Use flags from CI setup: --block-network, --timeout, -vv, --durations, etc.
# We run only the target test file, not all tests.
echo "=== Running Tests ==="
uv run pytest tests/test_project.py \
  --block-network \
  --timeout=30 \
  -vv \
  --durations=10 \
  --tb=short \
  --no-header \
  -rA
rc=$?

# Output the exit code for the judge
echo "OMNIGRIL_EXIT_CODE=$rc"

# Restore the test file to its original state
git checkout 1dc4f2e8977eb68b54dc3184a9548dfe10e57f3e "tests/test_project.py"
#!/bin/bash
set -uxo pipefail
cd /testbed

# Ensure the virtual environment is activated
source /testbed/.venv/bin/activate

# Load test environment variables
set -a
source /testbed/.env.test 2>/dev/null || true
set +a

# Set additional test environment variables
export CREWAI_STORAGE_DIR="/tmp/crewai_test_storage"
export CREWAI_TESTING="true"
export CREWAI_DISABLE_TELEMETRY="true"
export OTEL_SDK_DISABLED="true"
export PYTEST_VCR_RECORD_MODE="none"
export PYTHONUNBUFFERED="1"
export GITHUB_ACTIONS="false"

# Create storage directory
mkdir -p "$CREWAI_STORAGE_DIR"

# Reset the target test file to the original commit state
git checkout e43c7debbd444486df77c83fc604641e18f1cd8a "lib/crewai/tests/test_task.py"

# Apply the test patch
git apply -v - <<'EOF_114329324912'
diff --git a/lib/crewai/tests/test_task.py b/lib/crewai/tests/test_task.py
--- a/lib/crewai/tests/test_task.py
+++ b/lib/crewai/tests/test_task.py
@@ -1727,3 +1727,24 @@ def test_task_output_includes_messages():
     assert hasattr(task2_output, "messages")
     assert isinstance(task2_output.messages, list)
     assert len(task2_output.messages) > 0
+
+
+def test_async_execution_fails():
+    researcher = Agent(
+      role="Researcher",
+      goal="Make the best research and analysis on content about AI and AI agents",
+      backstory="You're an expert researcher, specialized in technology, software engineering, AI and startups. You work as a freelancer and is now working on doing research and analysis for a new customer.",
+      allow_delegation=False,
+    )
+
+    task = Task(
+      description="Give me a list of 5 interesting ideas to explore for na article, what makes them unique and interesting.",
+      expected_output="Bullet point list of 5 interesting ideas.",
+      async_execution=True,
+      agent=researcher,
+    )
+
+    with patch.object(Task, "_execute_core", side_effect=RuntimeError("boom!")):
+      with pytest.raises(RuntimeError, match="boom!"):
+        execution = task.execute_async(agent=researcher)
+        execution.result()
EOF_114329324912

# Run the target test file using uv run pytest with project-specific options
# Using the pytest wrapper that sets up the environment, but we already sourced it above
# We'll run directly with pytest after ensuring the environment is active
uv run pytest --tb=short -n auto --timeout=60 --dist=loadfile --max-worker-restart=2 --block-network --import-mode=importlib "lib/crewai/tests/test_task.py" -v
rc=$?  # Capture exit code immediately after test execution

echo "OMNIGRIL_EXIT_CODE=$rc"  # Required: echo test status

# Reset the target test file back to original state
git checkout e43c7debbd444486df77c83fc604641e18f1cd8a "lib/crewai/tests/test_task.py"
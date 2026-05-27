#!/bin/bash
set -uxo pipefail

# Change to testbed directory
cd /testbed

# Activate the virtual environment
source /testbed/.venv/bin/activate

# Verify environment is activated
python --version
pytest --version

# Ensure the test file is in the correct state from the specific commit
git checkout e43c7debbd444486df77c83fc604641e18f1cd8a "lib/crewai/tests/test_task.py"

# Apply test patch if needed
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

# Set critical environment variables for testing
export CREWAI_TESTING=true
export CREWAI_DISABLE_TELEMETRY=true
export OTEL_SDK_DISABLED=true
export CREWAI_TRACING_ENABLED=false
export PYTEST_VCR_RECORD_MODE=none
export PYTHONUNBUFFERED=1

# Set test API keys (fake keys for testing without real API calls)
export OPENAI_API_KEY=fake-api-key
export ANTHROPIC_API_KEY=fake-anthropic-key
export GEMINI_API_KEY=fake-gemini-key
export AZURE_API_KEY=fake-azure-key
export OPENROUTER_API_KEY=fake-openrouter-key
export AWS_ACCESS_KEY_ID=fake-aws-access-key
export AWS_SECRET_ACCESS_KEY=fake-aws-secret-key
export AWS_DEFAULT_REGION=us-east-1
export OPENAI_BASE_URL=https://api.openai.com/v1
export OPENAI_API_BASE=https://api.openai.com/v1

# Execute target test file using uv run pytest
uv run pytest lib/crewai/tests/test_task.py --tb=short -n auto --timeout=60 --dist=loadfile --max-worker-restart=2 --block-network --import-mode=importlib -v
rc=$?

# Echo the exit code for the test judge
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to the original commit state
git checkout e43c7debbd444486df77c83fc604641e18f1cd8a "lib/crewai/tests/test_task.py"

exit $rc
#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset the target test file to the checked-out commit state before patching
git checkout e43c7debbd444486df77c83fc604641e18f1cd8a "lib/crewai/tests/test_task.py"

# Apply test patch
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

# Activate the virtual environment created in the Dockerfile
source /testbed/venv/bin/activate

# Run pytest on the specified test file with concise and structured output, showing pass/fail/skip status
# -rA to show all extra test summary info, --tb=short for short tracebacks, no cacheprovider plugin for fresh output
# Use uv run pytest path/to/test_file.py as per context info with no parallelization here since only one test file
uv run pytest lib/crewai/tests/test_task.py -rA --tb=short -p no:cacheprovider

rc=$?            # Save exit code of test command

echo "OMNIGRIL_EXIT_CODE=$rc" # Report exit code for judge

# Reset the test file to clean state again
git checkout e43c7debbd444486df77c83fc604641e18f1cd8a "lib/crewai/tests/test_task.py"
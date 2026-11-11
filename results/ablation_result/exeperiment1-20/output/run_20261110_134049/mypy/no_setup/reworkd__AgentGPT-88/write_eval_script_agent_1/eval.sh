#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 9bae29c0727b7af51e0715ba6c20b00f7adefe33

# Apply the test patch
git apply -v - <<'EOF_114329324912'
diff --git a/platform/reworkd_platform/tests/agent/test_autonomous_agent_model_option.py b/platform/reworkd_platform/tests/agent/test_autonomous_agent_model_option.py
new file mode 100644
index 00000000..e69de29b
--- /dev/null
+++ b/platform/reworkd_platform/tests/agent/test_autonomous_agent_model_option.py
@@ -0,0 +1,28 @@
+import pytest
+from unittest.mock import patch, AsyncMock
+from src.components.AutonomousAgent import AutonomousAgent
+
+@pytest.mark.asyncio
+@patch('src.components.AutonomousAgent.axios.post')
+async def test_custom_model_name_passed_to_api(mock_post):
+    # Setup mock response
+    mock_post.return_value = AsyncMock()
+    mock_post.return_value.data = {"newTasks": ["task1", "task2"]}
+
+    agent = AutonomousAgent(
+        name="TestAgent",
+        goal="Test goal",
+        addMessage=lambda x: None,
+        shutdown=lambda: None,
+        customApiKey="fakekey",
+        customModelName="gpt-4"
+    )
+
+    tasks = await agent.getInitialTasks()
+    # Check that the model name was passed in the post data
+    mock_post.assert_called_with('/api/chain', {
+        'customApiKey': 'fakekey',
+        'customModelName': 'gpt-4',
+        'goal': 'Test goal'
+    })
+    assert tasks == ["task1", "task2"]
EOF_114329324912

# Run only the specified test file.
# As the repository uses Node.js/TypeScript with no explicit test command, use npm test with a pattern filter.
# Since no test framework details or npm test script is given,
# attempt to run the test via a direct call to node_modules/.bin/jest,
# filtering to the single test file (if jest is installed, typically).
# If jest or another test runner is not installed or the test file doesn't run this way, this may be adapted.

# Use npx jest with the path to the test file to run only the target test
npx jest --silent --passWithNoTests --outputFile=jest_output.json --json platform/reworkd_platform/tests/agent/test_autonomous_agent_model_option.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file to original state
git checkout 9bae29c0727b7af51e0715ba6c20b00f7adefe33 platform/reworkd_platform/tests/agent/test_autonomous_agent_model_option.py
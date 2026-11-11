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

# Confirm patch applied by listing the test directory contents
echo "Listing files under platform/reworkd_platform/tests/agent/:"
ls -l platform/reworkd_platform/tests/agent/ || echo "No such directory or files."

# No Python environment or test framework found; no pytest or python setup available.
# Also, the repository is Node.js/TypeScript and no test framework or test scripts are declared.
# Because test file is Python but not actually present in repo before patch, 
# and due to no Python environment, running the Python test is impossible.

# Thus, skip test execution but explicitly fail after patch application to mark no valid tests ran.

echo "No Python environment or test runner available."
echo "No test execution performed."
rc=1

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset repository to clear patch
git checkout 9bae29c0727b7af51e0715ba6c20b00f7adefe33
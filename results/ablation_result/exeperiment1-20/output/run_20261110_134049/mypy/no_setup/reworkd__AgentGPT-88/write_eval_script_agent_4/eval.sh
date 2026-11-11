#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 9bae29c0727b7af51e0715ba6c20b00f7adefe33

# Install Python3 and pip, and pytest for running Python tests
apt-get update && apt-get install -y python3 python3-pip
python3 -m pip install --upgrade pip
pip3 install pytest

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

# List files after patch to confirm existence
echo "Listing files under platform/reworkd_platform/tests/agent/:"
ls -l platform/reworkd_platform/tests/agent/ || echo "No such directory or files."

# Run the specific Python test file with pytest
pytest --tb=short --disable-warnings platform/reworkd_platform/tests/agent/test_autonomous_agent_model_option.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset repository to original state to clean up modified files
git checkout 9bae29c0727b7af51e0715ba6c20b00f7adefe33
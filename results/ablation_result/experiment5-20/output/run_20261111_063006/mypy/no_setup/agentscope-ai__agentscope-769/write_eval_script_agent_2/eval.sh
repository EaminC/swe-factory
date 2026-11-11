#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 811fb28a3dfd8c514e1b3f9fc10585069b35950d

git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_token_usage_vllm.py b/tests/test_token_usage_vllm.py
new file mode 100644
index 00000000..b1a2c3d4
--- /dev/null
+++ b/tests/test_token_usage_vllm.py
@@ -0,0 +1,36 @@
+import asyncio
+import pytest
+from agentscope.agent import ReActAgent, UserAgent
+from agentscope.model import OpenAIChatModel
+from agentscope.formatter import OpenAIChatFormatter
+from agentscope.memory import InMemoryMemory
+from agentscope.tool import Toolkit, execute_python_code, execute_shell_command
+
+@pytest.mark.asyncio
+async def test_token_usage_info_with_vllm_model():
+    toolkit = Toolkit()
+    toolkit.register_tool_function(execute_python_code)
+    toolkit.register_tool_function(execute_shell_command)
+
+    agent = ReActAgent(
+        name="Friday",
+        sys_prompt="You're a helpful assistant named Friday.",
+        model=OpenAIChatModel(
+            model_name="qwen3-coder-30b-a3b-instruct",
+            api_key="dummy_key",
+            stream=False,
+            client_args={"base_url": "http://dummy_base_url"}
+        ),
+        formatter=OpenAIChatFormatter(),
+        memory=InMemoryMemory(),
+        toolkit=toolkit,
+    )
+
+    user = UserAgent(name="user")
+
+    msg = None
+    # Send a simple message and check token usage info is present after response
+    msg = await agent(msg)
+    msg = await user(msg)
+    # The token usage info should be present in the agent's last response metadata
+    assert hasattr(agent.model, "last_token_usage") or hasattr(agent.model, "token_usage")
EOF_114329324912

# Activate the Python virtual environment
source /opt/venv/bin/activate

# Ensure pytest-cov is installed to support coverage options
pip install pytest-cov

# Check if the test file exists after patch application before running tests
if [[ -f "tests/test_token_usage_vllm.py" ]]; then
    pytest --no-header -rA --tb=short --cov=agentscope tests/test_token_usage_vllm.py
    rc=$?
else
    echo "Warning: tests/test_token_usage_vllm.py not found after applying patch, skipping pytest."
    rc=1
fi

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset repository state to clean patch effects; allow not-found errors to be ignored
git checkout 811fb28a3dfd8c514e1b3f9fc10585069b35950d || true
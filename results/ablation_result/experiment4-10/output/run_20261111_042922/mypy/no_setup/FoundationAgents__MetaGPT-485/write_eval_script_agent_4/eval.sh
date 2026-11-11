#!/bin/bash
set -uxo pipefail

source /opt/testbed/bin/activate

cd /testbed
git checkout 384f5ee08b6defef2adfb22274283e8bd0ef4314 

git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_retry_behavior.py b/tests/test_retry_behavior.py
new file mode 100644
index 00000000..e69de29bb
--- /dev/null
+++ b/tests/test_retry_behavior.py
@@ -0,0 +1,32 @@
+import asyncio
+import pytest
+from tenacity import RetryError
+from metagpt.actions.action import Action
+
+class DummyLLM:
+    def __init__(self):
+        self.call_count = 0
+
+    async def aask(self, prompt, system_msgs=None):
+        self.call_count += 1
+        # Fail first 5 times to simulate rate limit error, then succeed
+        if self.call_count <= 5:
+            raise Exception("Rate limit reached")
+        return "success"
+
+@pytest.mark.asyncio
+async def test_retry_decorator_allows_retries():
+    llm = DummyLLM()
+    action = Action(name="TestAction", llm=llm)
+
+    # Patch _aask_v1 to use DummyLLM and test retry behavior
+    async def dummy_aask_v1(prompt):
+        return await llm.aask(prompt)
+
+    action._aask_v1 = action._aask_v1.__func__.__get__(action)
+    action._aask_v1 = dummy_aask_v1
+
+    # The retry decorator should retry up to 6 times and eventually succeed
+    result = await action._aask_v1("prompt")
+    assert result == "success"
+    assert llm.call_count == 6
EOF_114329324912

export OPENAI_API_KEY="sk-REPLACE_WITH_VALID_KEY"

# Install pytest-asyncio to support async tests
pip install pytest-asyncio

pytest --no-header -rA --tb=short tests/test_retry_behavior.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset repository state
git checkout 384f5ee08b6defef2adfb22274283e8bd0ef4314
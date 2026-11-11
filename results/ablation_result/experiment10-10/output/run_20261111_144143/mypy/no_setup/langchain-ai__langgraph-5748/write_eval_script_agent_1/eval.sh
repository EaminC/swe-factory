#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 18887e9f86a6d8675a2b4aed03a1c190ef6e1581

# Apply the test patch
git apply -v - <<'EOF_114329324912'
diff --git a/libs/prebuilt/tests/test_create_react_agent_type.py b/libs/prebuilt/tests/test_create_react_agent_type.py
new file mode 100644
index 00000000..d3f4e2a1
--- /dev/null
+++ b/libs/prebuilt/tests/test_create_react_agent_type.py
@@ -0,0 +1,50 @@
+import pytest
+import asyncio
+from typing import Awaitable
+
+from langgraph.prebuilt.chat_agent_executor import create_react_agent
+from langgraph.prebuilt.chat_agent_executor import Runnable, LanguageModelInput, BaseMessage
+from langgraph.prebuilt.chat_agent_executor import StateSchema, Runtime
+
+class DummyRunnable(Runnable[LanguageModelInput, BaseMessage]):
+    def __init__(self):
+        self.called = False
+
+    def invoke(self, input: LanguageModelInput) -> BaseMessage:
+        self.called = True
+        return BaseMessage(content="response")
+
+    async def ainvoke(self, input: LanguageModelInput) -> BaseMessage:
+        self.called = True
+        return BaseMessage(content="async response")
+
+def dummy_dynamic_model(
+    state: StateSchema, runtime: Runtime
+) -> Runnable[LanguageModelInput, BaseMessage]:
+    return DummyRunnable()
+
+async def dummy_dynamic_model_async(
+    state: StateSchema, runtime: Runtime
+) -> Awaitable[Runnable[LanguageModelInput, BaseMessage]]:
+    await asyncio.sleep(0)
+    return DummyRunnable()
+
+def test_create_react_agent_accepts_runnable_dynamic_model():
+    # Should not raise type errors or runtime errors
+    agent = create_react_agent(
+        model=dummy_dynamic_model,
+        tools=[],
+        state_schema=StateSchema(),
+        runtime=Runtime(),
+    )
+    assert agent is not None
+
+@pytest.mark.asyncio
+async def test_create_react_agent_accepts_async_runnable_dynamic_model():
+    agent = create_react_agent(
+        model=dummy_dynamic_model_async,
+        tools=[],
+        state_schema=StateSchema(),
+        runtime=Runtime(),
+    )
+    assert agent is not None
EOF_114329324912

# Run pytest only on the specified test file with verbosity and strict options for clear output
# Using LANGGRAPH_TEST_FAST=1 as per environment default for fast in-memory tests without DB
LANGGRAPH_TEST_FAST=1 uv run pytest libs/prebuilt/tests/test_create_react_agent_type.py --strict-markers --strict-config --durations=5 -vv
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file and any modification after test run to ensure proper cleanup
git checkout 18887e9f86a6d8675a2b4aed03a1c190ef6e1581 libs/prebuilt/tests/test_create_react_agent_type.py
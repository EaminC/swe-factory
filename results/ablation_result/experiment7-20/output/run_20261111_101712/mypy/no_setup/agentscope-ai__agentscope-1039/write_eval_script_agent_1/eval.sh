#!/bin/bash
set -uxo pipefail

# Activate the python virtual environment
source /opt/testbed/bin/activate

cd /testbed
git checkout c245029a6f1094fbe72f58b353908127bea8269b 

# Apply the test patch (content replaced programmatically)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/react_agent_test.py b/tests/react_agent_test.py
new file mode 100644
index 00000000..e1a2b3c4
--- /dev/null
+++ b/tests/react_agent_test.py
@@ -0,0 +1,35 @@
+import asyncio
+import pytest
+
+from src.agentscope.agent._react_agent import ReActAgent, Msg
+
+class DummyMemory:
+    def __init__(self):
+        self.records = []
+    async def add(self, msg):
+        self.records.append(msg)
+
+@pytest.mark.asyncio
+async def test_static_control_records_longterm_memory():
+    agent = ReActAgent.__new__(ReActAgent)
+    agent.name = "test_agent"
+    agent.max_iters = 1
+    agent._static_control = True
+    agent.memory = DummyMemory()
+    
+    async def dummy_reasoning(tool_choice):
+        msg = Msg(agent.name, ["response text"], "assistant")
+        msg.metadata = {"structured": True}
+        return msg
+
+    agent._reasoning = dummy_reasoning
+    agent._summarizing = lambda: asyncio.Future()
+    fut = asyncio.Future()
+    fut.set_result(Msg(agent.name, ["summary"], "assistant"))
+    agent._summarizing = lambda: fut
+
+    reply = await agent._run_react_loop(tool_choice=None)
+    assert reply is not None
+    assert len(agent.memory.records) == 1
+    assert reply.metadata is not None
+
EOF_114329324912

git checkout c245029a6f1094fbe72f58b353908127bea8269b 

# Run only the specified test files with pytest
pytest -o log_cli=false --maxfail=5 --disable-warnings --tb=short --capture=no --color=yes -rA tests/react_agent_test.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test files after running tests to clean any patch effect
git checkout c245029a6f1094fbe72f58b353908127bea8269b "tests/react_agent_test.py"
#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 28cfb99a21902d330dab6cb3762a739198cf972f tests/hooks/test_studio_hooks.py

# Apply the test patch to update target tests
git apply -v - <<'EOF_114329324912'
diff --git a/tests/hooks/test_studio_hooks.py b/tests/hooks/test_studio_hooks.py
new file mode 100644
index 0000000..e1a2b3c
--- /dev/null
+++ b/tests/hooks/test_studio_hooks.py
@@ -0,0 +1,36 @@
+import asyncio
+import pytest
+from agentscope.agent import AgentBase
+from agentscope.message import Msg, TextBlock
+from agentscope.hooks._studio_hooks import as_studio_forward_message_pre_print_hook
+
+class TestAgent(AgentBase):
+    def __init__(self, name: str):
+        super().__init__()
+        self.name = name
+        self._disable_console_output = False
+    
+    async def reply(self, msg: Msg) -> Msg:
+        await self.print(msg)
+        return msg
+    
+    async def observe(self, msg: Msg) -> None:
+        pass
+    
+    async def handle_interrupt(self, *args, **kwargs) -> Msg:
+        return Msg("test", "Interrupt handled", "assistant")
+
+TestAgent.register_class_hook(
+    "pre_print",
+    "studio_forward",
+    lambda self, kwargs: as_studio_forward_message_pre_print_hook(
+        self, kwargs, studio_url="http://127.0.0.1:9999", run_id="test"
+    ),
+)
+
+@pytest.mark.asyncio
+async def test_studio_hook_graceful_degradation():
+    agent = TestAgent(name="TestAgent")
+    msg = Msg("user", [TextBlock(type="text", text="Hello")], "user")
+    # Should not raise despite connection failure
+    await agent.reply(msg)
EOF_114329324912

# Run only the specified target test file; output concise test results with file names and status
pytest -q --tb=short --disable-warnings --maxfail=1 tests/hooks/test_studio_hooks.py
rc=$?            # Required, save exit code

echo "OMNIGRIL_EXIT_CODE=$rc" # Required, echo test status

# Revert changes on the test file to keep clean state
git checkout 28cfb99a21902d330dab6cb3762a739198cf972f tests/hooks/test_studio_hooks.py
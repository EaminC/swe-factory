#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 08b047e05b02b27a290ee1b850fb75210f186cdb

git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_deep_research_agent_blocks.py b/tests/test_deep_research_agent_blocks.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_deep_research_agent_blocks.py
@@ -0,0 +1,35 @@
+import pytest
+
+from examples.agent.deep_research_agent import deep_research_agent
+
+class DummyAgent(deep_research_agent.DeepResearchAgent):
+    def __init__(self):
+        # no need to call super().__init__ for this test
+        pass
+
+@pytest.mark.parametrize("blocks,expected_text", [
+    (
+        [
+            {"type": "thinking", "thinking": "processing..."},
+            {"type": "text", "text": "final text content"}
+        ],
+        "final text content"
+    ),
+    (
+        [
+            {"type": "text", "text": "only text block"}
+        ],
+        "only text block"
+    ),
+])
+def test_extract_text_from_blocks_handles_thinking_blocks(blocks, expected_text):
+    agent = DummyAgent()
+    result = agent._extract_text_from_blocks(blocks)
+    assert result == expected_text
+
+def test_extract_text_from_blocks_raises_on_no_text_block():
+    agent = DummyAgent()
+    blocks = [{"type": "thinking", "thinking": "no text here"}]
+    with pytest.raises(ValueError) as excinfo:
+        agent._extract_text_from_blocks(blocks)
+    assert "No text block found" in str(excinfo.value)
EOF_114329324912

source /testbed/testbed_env/bin/activate

# Install pytest explicitly since it is not pre-installed
pip install --no-cache-dir pytest

# Run only the specified target test file with concise output showing test outcomes
pytest -q --disable-warnings --tb=short tests/test_deep_research_agent_blocks.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"
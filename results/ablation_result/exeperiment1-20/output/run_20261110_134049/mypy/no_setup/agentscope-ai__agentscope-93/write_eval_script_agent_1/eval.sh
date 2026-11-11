#!/bin/bash
set -uxo pipefail

# Activate conda environment
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed

cd /testbed
git checkout 17676eaaf2346ff936fc2df78ec098fa7a81e3e0 

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_text_to_image_agent.py b/tests/test_text_to_image_agent.py
new file mode 100644
index 00000000..b1f4e2d7
--- /dev/null
+++ b/tests/test_text_to_image_agent.py
@@ -0,0 +1,41 @@
+import pytest
+from agentscope.agents.text_to_image_agent import TextToImageAgent
+from agentscope.message import Msg
+
+class DummyModel:
+    def __call__(self, content):
+        class Result:
+            image_urls = ["http://dummyimage.com/generated"]
+        return Result()
+
+@pytest.fixture
+def agent():
+    agent = TextToImageAgent(name="painter", model_config_name="dummy")
+    agent.model = DummyModel()
+    # clear memory if any
+    if agent.memory:
+        agent.memory.clear()
+    return agent
+
+def test_reply_with_explicit_msg(agent):
+    msg = Msg(name="assistants", content="A beautiful sunset over the mountains.")
+    response = agent.reply(msg)
+    assert isinstance(response, dict)
+    assert "content" in response
+    assert "url" in response
+    assert response["url"] == ["http://dummyimage.com/generated"]
+
+def test_reply_without_msg_uses_memory(agent):
+    msg = Msg(name="assistants", content="A futuristic city skyline at night.")
+    agent.memory.add(msg)
+    response = agent.reply()
+    assert isinstance(response, dict)
+    assert "content" in response
+    assert "url" in response
+    assert response["url"] == ["http://dummyimage.com/generated"]
+
+def test_reply_without_msg_and_empty_memory(agent):
+    if agent.memory:
+        agent.memory.clear()
+    response = agent.reply()
+    assert response == {}
EOF_114329324912

# Run only the specified test file with concise output of test names and statuses
pytest --tb=short -r a --disable-warnings -q tests/test_text_to_image_agent.py
rc=$?            # Save exit code immediately after test run

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset any modified files to clean state after test execution
git checkout 17676eaaf2346ff936fc2df78ec098fa7a81e3e0 tests/test_text_to_image_agent.py
#!/bin/bash
set -uxo pipefail

cd /testbed

# Ensure we are on the target commit and reset any changes before starting
git checkout b95f56b446a2fe55247eee717ab85fe45f857d27

# Apply test patch (content replaced at runtime)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_clarify_dataset.py b/tests/test_clarify_dataset.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_clarify_dataset.py
@@ -0,0 +1,38 @@
+import pytest
+from unittest.mock import MagicMock
+from mle.agents.advisor import AdviseAgent
+
+class DummyModel:
+    def __init__(self, responses):
+        self.responses = responses
+        self.call_count = 0
+    def query(self, chat_history, response_format=None):
+        resp = self.responses[self.call_count]
+        self.call_count += 1
+        return resp
+
+class DummyConsole:
+    def status(self, msg):
+        class DummyStatus:
+            def __enter__(self_):
+                return self_
+            def __exit__(self_, exc_type, exc_val, exc_tb):
+                pass
+        return DummyStatus()
+
+def test_clarify_dataset_blur():
+    # simulate model responses: first 'No' means unclear dataset, second is JSON suggestion
+    responses = ["No", '{"datasets": ["MNIST", "CIFAR-10", "ImageNet"], "reason": "Based on the user's dataset description."}']
+    model = DummyModel(responses)
+    console = DummyConsole()
+    agent = AdviseAgent(model, console)
+    result = agent.clarify_dataset("blur dataset name")
+    assert result in ["MNIST", "CIFAR-10", "ImageNet"]
+
+def test_clarify_dataset_clear():
+    # simulate model response 'Yes' means dataset is clear, so clarify_dataset returns None
+    model = DummyModel(["Yes"])
+    console = DummyConsole()
+    agent = AdviseAgent(model, console)
+    result = agent.clarify_dataset("MNIST")
+    assert result is None
EOF_114329324912

# Run only the required test files using unittest in verbose mode to show test names and results
# Activate the virtual environment explicitly (though $PATH is set in Dockerfile, be explicit here)
source /opt/testbed/bin/activate

# Run unittest for the target test file(s) only, with verbose for detailed output
python -m unittest -v tests/test_clarify_dataset.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset changes after test run to cleanup environment
git checkout b95f56b446a2fe55247eee717ab85fe45f857d27
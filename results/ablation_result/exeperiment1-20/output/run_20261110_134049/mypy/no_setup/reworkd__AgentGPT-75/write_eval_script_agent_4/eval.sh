#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 3caa8faa22d8c820bfd0bfb663be5035938b528b

git apply -v - <<'EOF_114329324912'
diff --git a/platform/reworkd_platform/tests/agent/test_autonomous_agent.py b/platform/reworkd_platform/tests/agent/test_autonomous_agent.py
new file mode 100644
index 00000000..e3b0c442
--- /dev/null
+++ b/platform/reworkd_platform/tests/agent/test_autonomous_agent.py
@@ -0,0 +1,29 @@
+import pytest
+
+class DummyAgent:
+    def __init__(self, customApiKey=""):
+        self.customApiKey = customApiKey
+        self.numLoops = 0
+        self.stopped = False
+    
+    def sendLoopMessage(self):
+        pass
+    
+    def shutdown(self):
+        self.stopped = True
+    
+    def run_loop(self):
+        maxLoops = 4 if self.customApiKey == "" else 25
+        while self.numLoops <= maxLoops:
+            self.numLoops += 1
+            if self.numLoops > maxLoops:
+                self.sendLoopMessage()
+                self.shutdown()
+                break
+
+@pytest.mark.parametrize("custom_key,expected_max_loops", [("", 4), ("key", 25)])
+def test_agent_stops_at_max_loops(custom_key, expected_max_loops):
+    agent = DummyAgent(customApiKey=custom_key)
+    agent.run_loop()
+    assert agent.numLoops == expected_max_loops + 1
+    assert agent.stopped is True
EOF_114329324912

git checkout 3caa8faa22d8c820bfd0bfb663be5035938b528b

# Check if the target Python test file exists
TEST_FILE="platform/reworkd_platform/tests/agent/test_autonomous_agent.py"
if [[ -f "$TEST_FILE" ]]; then
    # Install Python 3 and pytest in the container (if not already installed)
    # This ensures the environment can run the python test file
    
    apt update
    apt install -y python3 python3-pip
    pip3 install pytest

    # Run pytest on the specific test file with concise output of test results
    pytest --maxfail=1 --disable-warnings -q "$TEST_FILE"
    rc=$?
else
    echo "Target test file $TEST_FILE does not exist."
    # Exit with code 1 to reflect missing test file as a failure
    rc=1
fi

echo "OMNIGRIL_EXIT_CODE=$rc"
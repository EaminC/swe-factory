#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout f761cf215fbd1f0a1e57eb2d073229628b77f462 "tests/rpc_agent_test.py"
git apply -v - <<'EOF_114329324912'
diff --git a/tests/rpc_agent_test.py b/tests/rpc_agent_test.py
--- a/tests/rpc_agent_test.py
+++ b/tests/rpc_agent_test.py
@@ -4,6 +4,7 @@
 """
 import unittest
 import time
+import os
 import shutil
 from loguru import logger
 
@@ -159,14 +160,15 @@ def setUp(self) -> None:
         agentscope.init(
             project="test",
             name="rpc_agent",
-            save_dir="./test_runs",
+            save_dir="./.unittest_runs",
             save_log=True,
         )
+        self.assertTrue(os.path.exists("./.unittest_runs"))
 
     def tearDown(self) -> None:
         MonitorFactory._instance = None  # pylint: disable=W0212
         logger.remove()
-        shutil.rmtree("./test_runs")
+        shutil.rmtree("./.unittest_runs")
 
     def test_single_rpc_agent_server(self) -> None:
         """test setup a single rpc agent"""
EOF_114329324912

# Activate the virtual environment
source /opt/testbed/bin/activate

# Run the specified test file directly with pytest under coverage
coverage run -m pytest tests/rpc_agent_test.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Restore the patched test file to original state
git checkout f761cf215fbd1f0a1e57eb2d073229628b77f462 "tests/rpc_agent_test.py"
#!/bin/bash
set -uxo pipefail

# Activate conda environment
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed

cd /testbed

# Ensure test files are at the target commit state before applying patch
git checkout f761cf215fbd1f0a1e57eb2d073229628b77f462 "tests/rpc_agent_test.py"

# Apply the test patch
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

# Run the specific test file with pytest
# Use --no-header and --tb=no for cleaner output, -rA to show all test results
pytest --no-header -rA --tb=no -p no:cacheprovider "tests/rpc_agent_test.py"
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Revert the test file to original commit state after execution
git checkout f761cf215fbd1f0a1e57eb2d073229628b77f462 "tests/rpc_agent_test.py"
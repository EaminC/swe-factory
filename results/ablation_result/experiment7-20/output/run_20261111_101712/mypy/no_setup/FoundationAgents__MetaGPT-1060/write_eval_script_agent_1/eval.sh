#!/bin/bash
set -uxo pipefail

source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed

cd /testbed

git checkout 0958cc333ee13d1ce5216ae0bdeaa53b5eacc6ea

git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_timeout_config.py b/tests/test_timeout_config.py
new file mode 100644
index 00000000..e69de29bb
--- /dev/null
+++ b/tests/test_timeout_config.py
@@ -0,0 +1,21 @@
+import asyncio
+import pytest
+from metagpt.roles.di.data_interpreter import DataInterpreter
+
+@pytest.mark.asyncio
+async def test_data_interpreter_runs_with_timeout_config():
+    # This test ensures that DataInterpreter.run() completes without ReadTimeout
+    # when using the updated timeout configuration from the patch.
+    di = DataInterpreter()
+    requirement = (
+        "Create a dnd 5th edition graph displaying xp per level based on information from a reputable source "
+        "determined by Googling. First write results in a CSV and validate the CSV contains multiple records. "
+        "If the file does not contain records, determine if you can fix the code or whether you need to look at another source. "
+        "After the CSV files is filled with records, create the graph based on this."
+    )
+
+    # Run the interpreter and ensure it completes without raising exceptions
+    try:
+        await di.run(requirement)
+    except Exception as e:
+        pytest.fail(f"DataInterpreter.run() raised an unexpected exception: {e}")
EOF_114329324912

# Run only the specified test file with concise output showing file and status of tests
pytest --no-header -rA --tb=short tests/test_timeout_config.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset the test file to original state
git checkout 0958cc333ee13d1ce5216ae0bdeaa53b5eacc6ea -- tests/test_timeout_config.py
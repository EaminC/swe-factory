#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout e655412aca3f7acb9852473b9d336372e635f8ce

# Apply the patch for test modifications if any
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_reset_memories.py b/tests/test_reset_memories.py
new file mode 100644
index 00000000..e1a2b3c4
--- /dev/null
+++ b/tests/test_reset_memories.py
@@ -0,0 +1,26 @@
+import subprocess
+import sys
+import os
+import tempfile
+
+import pytest
+
+def test_reset_memories_no_crew(monkeypatch):
+    # Create a temporary directory to simulate a crew project without a crew
+    with tempfile.TemporaryDirectory() as tmpdir:
+        # Change to the temp directory
+        old_cwd = os.getcwd()
+        os.chdir(tmpdir)
+        try:
+            # Run the CLI command `crewai reset-memories --knowledge`
+            result = subprocess.run(
+                [sys.executable, "-m", "crewai", "reset-memories", "--knowledge"],
+                capture_output=True,
+                text=True,
+            )
+            # The output should contain the expected error message about memory system not initialized
+            assert "Failed to reset knowledge memory: knowledge memory system is not initialized" in result.stderr or \
+                   "Failed to reset knowledge memory: knowledge memory system is not initialized" in result.stdout
+        finally:
+            os.chdir(old_cwd)
+
EOF_114329324912

# Activate the virtual environment
source /opt/testbed/bin/activate

# Run only the specified test file with verbose output showing test file names and their statuses
pytest -v tests/test_reset_memories.py

rc=$?  # Capture exit code of pytest

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset any modifications after test run to keep repo clean
git checkout e655412aca3f7acb9852473b9d336372e635f8ce tests/test_reset_memories.py
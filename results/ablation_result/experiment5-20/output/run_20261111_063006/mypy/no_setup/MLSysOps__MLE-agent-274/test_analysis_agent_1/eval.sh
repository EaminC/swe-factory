#!/bin/bash
set -uxo pipefail

cd /testbed

# Ensure we are on the correct commit
git checkout ea7393b7c5e6009b77bcac00f41dd5dcfd41df7a

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_lancedbmemory.py b/tests/test_lancedbmemory.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_lancedbmemory.py
@@ -0,0 +1,18 @@
+import os
+import pytest
+from mle.utils import LanceDBMemory
+
+def test_lancedbmemory_init_with_no_config(tmp_path):
+    # Simulate a directory with no config file or config returns None
+    os.chdir(tmp_path)
+    # LanceDBMemory should handle missing or None config gracefully
+    # and not raise TypeError when accessing config["platform"]
+    try:
+        memory = LanceDBMemory(str(tmp_path))
+    except TypeError:
+        pytest.fail("LanceDBMemory raised TypeError on missing config")
+
+    # If LanceDBMemory exposes config attribute, it should be None or dict
+    if hasattr(memory, 'config'):
+        assert memory.config is None or isinstance(memory.config, dict)
+
EOF_114329324912

# Run only the specified test file using unittest discover and pattern option
python -m unittest discover -s tests -p test_lancedbmemory.py -v
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset the repository to discard patch changes
git checkout ea7393b7c5e6009b77bcac00f41dd5dcfd41df7a
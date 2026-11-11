#!/bin/bash
set -uxo pipefail

# Activate the virtual environment created by uv
source /opt/testbed/bin/activate

cd /testbed

git checkout c4f7eaf2599c5709260d660d48e810aae7a8c124

# Apply the test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/memory/test_rag_storage_reset.py b/tests/memory/test_rag_storage_reset.py
new file mode 100644
index 0000000..e1a2f3b
--- /dev/null
+++ b/tests/memory/test_rag_storage_reset.py
@@ -0,0 +1,43 @@
+import os
+import shutil
+import pytest
+from unittest import mock
+
+from src.crewai.memory.storage import rag_storage
+from crewai.utilities.paths import db_storage_path
+
+class DummyApp:
+    def __init__(self):
+        self.reset_called = False
+    def reset(self):
+        self.reset_called = True
+
+@pytest.fixture
+def rag_storage_instance(tmp_path):
+    instance = rag_storage.RAGStorage()
+    instance.type = "test_type"
+    instance.app = DummyApp()
+    instance.collection = object()
+    # Setup dummy directory to simulate storage path
+    storage_dir = os.path.join(db_storage_path(), instance.type)
+    os.makedirs(storage_dir, exist_ok=True)
+    yield instance
+    # Cleanup after test
+    if os.path.exists(storage_dir):
+        shutil.rmtree(storage_dir)
+
+def test_reset_clears_storage_and_resets_app(rag_storage_instance):
+    instance = rag_storage_instance
+    storage_dir = os.path.join(db_storage_path(), instance.type)
+    # Create a dummy file to ensure directory exists
+    dummy_file = os.path.join(storage_dir, "dummy.txt")
+    with open(dummy_file, "w") as f:
+        f.write("data")
+
+    instance.reset()
+
+    # After reset, directory should be removed
+    assert not os.path.exists(storage_dir)
+    # app.reset() should have been called
+    assert instance.app is None
+    assert instance.collection is None
EOF_114329324912

# Run only the specified target test file with uv run pytest and output concise results
uv run pytest -v --tb=short tests/memory/test_rag_storage_reset.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset any modifications to the repository after test run
git checkout c4f7eaf2599c5709260d660d48e810aae7a8c124 tests/memory/test_rag_storage_reset.py
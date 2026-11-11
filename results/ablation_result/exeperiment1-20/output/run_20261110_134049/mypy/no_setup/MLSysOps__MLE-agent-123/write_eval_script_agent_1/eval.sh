#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout cc7d248e9ec8f9359d7454017ddc6a31bde840b4

# Apply test patch (content to be replaced during execution)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_cache.py b/tests/test_cache.py
new file mode 100644
index 0000000..e1a2b3c
--- /dev/null
+++ b/tests/test_cache.py
@@ -0,0 +1,44 @@
+import pytest
+import pickle
+from datetime import datetime
+from mle.utils.cache import WorkflowCache
+
+class DummyCache:
+    def __init__(self):
+        self.stored = False
+    def _store_cache_buffer(self):
+        self.stored = True
+
+def test_workflow_cache_store_and_resume(tmp_path):
+    # Setup WorkflowCache with dummy project dir
+    cache = WorkflowCache(str(tmp_path))
+    step = 1
+    name = "test_step"
+    operator = cache(step, name)
+
+    # Initially cache should be empty
+    assert cache.is_empty() or step in cache.cache
+
+    # Store a value
+    test_key = "key"
+    test_value = {"a": 123}
+    operator.store(test_key, test_value)
+    # The value should be stored as pickled bytes
+    assert isinstance(cache.cache[step]["content"][test_key], bytes)
+
+    # Resume the value
+    resumed_value = operator.resume(test_key)
+    assert resumed_value == test_value
+
+    # Resume a non-existing key returns None
+    assert operator.resume("nonexistent") is None
+
+    # Test context manager calls _store_cache_buffer
+    dummy_cache = DummyCache()
+    dummy_cache.cache = {step: {"content": {}}}
+    dummy_cache.buffer = {"cache": dummy_cache.cache}
+    dummy_cache.__class__ = WorkflowCache
+    dummy_cache._store_cache_buffer = lambda: setattr(dummy_cache, "stored", True)
+    with dummy_cache(step, name) as op:
+        op.store(test_key, test_value)
+    assert dummy_cache.stored
EOF_114329324912

# Activate virtual environment and run only the specified test file with unittest
source /opt/testbed/bin/activate

python -m unittest tests/test_cache.py -v
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to clean any patch effect
git checkout cc7d248e9ec8f9359d7454017ddc6a31bde840b4 tests/test_cache.py
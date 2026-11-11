#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout dd7da4e5ac4085fb8324cac3ac0b4c104b9007cb

# Apply the test patch to update target tests
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_memory_api.py b/tests/test_memory_api.py
new file mode 100644
index 0000000..e3f1a2b
--- /dev/null
+++ b/tests/test_memory_api.py
@@ -0,0 +1,31 @@
+import pytest
+from mle.utils import memory
+
+def test_memory_add_and_list_keys(tmp_path):
+    # Initialize memory with a temporary project path
+    mem = memory.ChromaDBMemory(str(tmp_path))
+
+    # Add queries
+    queries = [
+        {"query": "key1", "response": "value1"},
+        {"query": "key2", "response": "value2"}
+    ]
+    ids = mem.add_query(queries)
+    assert len(ids) == 2
+
+    # Peek keys only (simulate list keys by peeking and extracting ids)
+    peeked = mem.peek()
+    keys = [item['id'] for item in peeked['ids']] if 'ids' in peeked else []
+    # The keys returned by peek should include the added ids
+    assert any(id_ in keys for id_ in ids)
+
+    # Test get method returns data for one id
+    record = mem.get(record_id=ids[0])
+    assert record is not None
+    assert 'documents' in record or 'metadatas' in record
+
+    # Test delete collection
+    mem.delete()
+    # After delete, peek should return empty or raise
+    with pytest.raises(Exception):
+        mem.peek()
EOF_114329324912

# Activate the virtual environment
source /opt/testbed/bin/activate

# Downgrade numpy to a compatible version <2.0 to avoid ImportError with lancedb
pip install --no-cache-dir "numpy<2.0,>=1.24"

# Reinstall lancedb after fixing numpy to ensure compatibility
pip install --no-cache-dir --force-reinstall "lancedb~=0.15.0"

# Ensure pytest is installed for running tests
pip install --no-cache-dir pytest

# Run only the specified test file with pytest, concise output
pytest -q --tb=short --disable-warnings tests/test_memory_api.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout dd7da4e5ac4085fb8324cac3ac0b4c104b9007cb tests/test_memory_api.py
#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 9e9b945a4662e6cea9f6ca621cac3224a3119622 

# Apply the test patch (content replaced programmatically)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/memory/storage/test_rag_storage_path.py b/tests/memory/storage/test_rag_storage_path.py
new file mode 100644
index 00000000..e69de29bb
--- /dev/null
+++ b/tests/memory/storage/test_rag_storage_path.py
@@ -0,0 +1,30 @@
+import pytest
+import os
+from crewai.memory.storage import rag_storage
+
+class DummyCrew:
+    def __init__(self):
+        self.agents = [type('Agent', (), {'role': 'testrole'})()]
+
+def test_ragstorage_custom_path(monkeypatch, tmp_path):
+    # Patch chromadb.PersistentClient to capture the path argument
+    captured = {}
+
+    class DummyPersistentClient:
+        def __init__(self, path, settings):
+            captured['path'] = path
+            self._collections = {}
+        def get_collection(self, name, embedding_function=None):
+            if name not in self._collections:
+                raise Exception('Collection not found')
+            return self._collections[name]
+        def create_collection(self, name, embedding_function=None):
+            self._collections[name] = 'dummy_collection'
+            return self._collections[name]
+
+    monkeypatch.setattr(rag_storage.chromadb, 'PersistentClient', DummyPersistentClient)
+
+    custom_path = str(tmp_path / 'custom_db')
+    crew = DummyCrew()
+    storage = rag_storage.RAGStorage(type='short_term', crew=crew, path=custom_path)
+    assert captured['path'] == custom_path
EOF_114329324912

# Run only the specified target test file(s) with verbosity as per collected command, limiting to given file(s)
# Using 'uv run pytest' as gathered from context
uv run pytest -vv tests/memory/storage/test_rag_storage_path.py
rc=$?            #Required, save exit code

echo "OMNIGRIL_EXIT_CODE=$rc" #Required, output the test result code

# Revert the changes caused by the patch to keep clean state after test run
git checkout 9e9b945a4662e6cea9f6ca621cac3224a3119622 tests/memory/storage/test_rag_storage_path.py
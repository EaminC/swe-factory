#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 409892d65fab88e4a390f05c46b399b5a9260463

git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_knowledge_embedder.py b/tests/test_knowledge_embedder.py
new file mode 100644
index 0000000..e1a2b3c
--- /dev/null
+++ b/tests/test_knowledge_embedder.py
@@ -0,0 +1,37 @@
+import pytest
+from pathlib import Path
+from crewai.knowledge.source.base_knowledge_source import BaseKnowledgeSource
+from crewai.knowledge.source.base_file_knowledge_source import BaseFileKnowledgeSource
+from crewai.knowledge.knowledge import Knowledge
+from crewai.knowledge.storage.knowledge_storage import KnowledgeStorage
+from pydantic import ValidationError
+
+class DummyKnowledgeStorage(KnowledgeStorage):
+    def save(self, chunks):
+        self.saved_chunks = chunks
+
+class DummyKnowledgeSource(BaseKnowledgeSource):
+    def __init__(self, **data):
+        super().__init__(**data)
+        self.chunks = ["chunk1", "chunk2"]
+
+@pytest.fixture
+def dummy_storage():
+    return DummyKnowledgeStorage()
+
+def test_storage_optional_and_embedder_config():
+    # Test Knowledge with storage=None and embedder_config set
+    knowledge = Knowledge(sources=[], storage=None, embedder_config={"provider": "watson", "config": {"model": "ibm/slate-125m-english-rtrvr"}})
+    assert knowledge.storage is None
+    assert knowledge.embedder_config["provider"] == "watson"
+
+def test_base_knowledge_source_storage_none_raises_on_save():
+    source = DummyKnowledgeSource(storage=None)
+    with pytest.raises(ValueError, match="No storage found to save documents."):
+        source._save_documents()
+
+def test_base_file_knowledge_source_storage_none_raises_on_save():
+    source = BaseFileKnowledgeSource(file_path=[Path("/tmp/file.txt")], storage=None)
+    source.chunks = ["chunk1"]
+    with pytest.raises(ValueError, match="No storage found to save documents."):
+        source._save_documents()
EOF_114329324912

# Activate the virtual environment
source /testbed/.venv/bin/activate

# Run only the specified test file using uv run pytest command
uv run pytest -vv tests/test_knowledge_embedder.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file to original state to clean up any changes from the patch
git checkout 409892d65fab88e4a390f05c46b399b5a9260463 tests/test_knowledge_embedder.py
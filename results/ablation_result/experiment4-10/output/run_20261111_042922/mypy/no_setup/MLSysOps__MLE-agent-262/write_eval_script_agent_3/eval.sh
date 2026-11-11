#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 96a84c48ce271d37749c6304866e42a24e6647ac

# Apply the test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_memory_lancedb.py b/tests/test_memory_lancedb.py
new file mode 100644
index 0000000..d1f2a3b
--- /dev/null
+++ b/tests/test_memory_lancedb.py
@@ -0,0 +1,52 @@
+import os
+import pytest
+import uuid
+from mle.utils.memory import LanceDBMemory
+
+class DummyEmbedding:
+    def compute_source_embeddings(self, texts):
+        # Return a list of dummy embeddings (list of floats) for each text
+        return [[float(len(text))] * 3 for text in texts]
+
+class DummyRegistry:
+    def get(self, name):
+        return DummyEmbedding()
+
+def dummy_get_registry():
+    return DummyRegistry()
+
+def dummy_get_config(path):
+    return {"platform": "OpenAI", "api_key": "dummy_key"}
+
+@pytest.fixture(autouse=True)
+def patch_dependencies(monkeypatch):
+    monkeypatch.setattr("mle.utils.memory.get_registry", dummy_get_registry)
+    monkeypatch.setattr("mle.utils.memory.get_config", dummy_get_config)
+
+@pytest.fixture
+def memory(tmp_path):
+    # Use a temporary directory for project path
+    mem = LanceDBMemory(str(tmp_path))
+    # Clear any existing tables
+    for table_name in mem.client.table_names():
+        mem.client.drop_table(table_name)
+    return mem
+
+def test_add_and_query(memory):
+    texts = ["hello world", "test text"]
+    ids = memory.add(texts)
+    assert len(ids) == 2
+    results = memory.query(["hello"])
+    assert isinstance(results, list)
+    assert len(results) == 1
+    assert all(isinstance(r, dict) for r in results[0])
+
+def test_delete(memory):
+    text = "to be deleted"
+    ids = memory.add([text])
+    record_id = ids[0]
+    deleted = memory.delete(record_id)
+    assert deleted is True
+    # Deleting again should return False
+    deleted_again = memory.delete(record_id)
+    assert deleted_again is False
EOF_114329324912

# Activate the python virtual environment
source /opt/testbed/bin/activate

# Setup minimal required config file to avoid AttributeError in embedding setup
# Create config.yaml with platform not OpenAI to avoid requiring API key, using default local embedding
mkdir -p config
cat > config/config.yaml <<'EOCFG'
memory:
  backend: chromadb
  persist_directory: "./tmp/chroma"
  embedding_function: null
  platform: Local
  api_key: null
EOCFG

export MLE_AGENT_CONFIG_PATH=/testbed/config/config.yaml

# Run only the specified test file with pytest for proper test discovery
pytest -v tests/test_memory_lancedb.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup config file to reset environment
rm -rf /testbed/config

# Reset any changes after test run
git checkout 96a84c48ce271d37749c6304866e42a24e6647ac
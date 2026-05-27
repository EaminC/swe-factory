#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset target test file to exact commit version to ensure clean state
git checkout cb522cf5005f856b21c6976e8d94709ae4f9c3f3 tests/utilities/test_embedding_configuration.py

# Apply test patch to update target test file(s)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/utilities/test_embedding_configuration.py b/tests/utilities/test_embedding_configuration.py
new file mode 100644
--- /dev/null
+++ b/tests/utilities/test_embedding_configuration.py
@@ -0,0 +1,25 @@
+from unittest.mock import patch
+
+import pytest
+
+from crewai.rag.embeddings.configurator import EmbeddingConfigurator
+
+
+def test_configure_embedder_importerror():
+    configurator = EmbeddingConfigurator()
+    
+    embedder_config = {
+        'provider': 'openai',
+        'config': {
+            'model': 'text-embedding-ada-002',
+        }
+    }
+    
+    with patch('chromadb.utils.embedding_functions.openai_embedding_function.OpenAIEmbeddingFunction') as mock_openai:
+        mock_openai.side_effect = ImportError("Module not found.")
+        
+        with pytest.raises(ImportError) as exc_info:
+            configurator.configure_embedder(embedder_config)
+
+        assert str(exc_info.value) == "Module not found."
+        mock_openai.assert_called_once()
EOF_114329324912

# Activate the Python virtual environment for running tests
source /opt/testbed/bin/activate

# Run only the specified test file with pytest under "uv run" as recommended by the environment
uv run pytest tests/utilities/test_embedding_configuration.py --tb=short -rA --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file after running tests to keep repo clean
git checkout cb522cf5005f856b21c6976e8d94709ae4f9c3f3 tests/utilities/test_embedding_configuration.py
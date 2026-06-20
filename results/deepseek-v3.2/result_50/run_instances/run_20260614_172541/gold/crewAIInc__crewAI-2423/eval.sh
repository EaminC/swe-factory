#!/bin/bash
set -uxo pipefail

# Activate the virtual environment
source /testbed/.venv/bin/activate

# Navigate to the repository root
cd /testbed

# Ensure we are at the correct commit
git checkout cb522cf5005f856b21c6976e8d94709ae4f9c3f3

# Apply the test patch
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

# Execute only the specified target test file using the project's test command
uv run pytest --no-header -rA --tb=no -p no:cacheprovider tests/utilities/test_embedding_configuration.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Revert the test patch to clean up
git checkout cb522cf5005f856b21c6976e8d94709ae4f9c3f3
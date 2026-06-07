#!/bin/bash
set -uxo pipefail

cd /testbed

# Checkout entire commit to ensure clean state (no individual test file checkout due to missing file)
git checkout cb522cf5005f856b21c6976e8d94709ae4f9c3f3

# Apply test patch (replace [CONTENT OF TEST PATCH] with actual patch content at runtime)
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

# Export required environment variables
export OPENAI_API_KEY="your_openai_api_key_here"
export SERPER_API_KEY="your_serper_api_key_here"
export OTEL_SDK_DISABLED="true"
export share_crew="True"

# Run only the specified test file(s) with proper uv command
uv run pytest tests/utilities/test_embedding_configuration.py --tb=short -rA --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset repository state to the original commit after tests (full reset due to absence of individual test file)
git reset --hard cb522cf5005f856b21c6976e8d94709ae4f9c3f3
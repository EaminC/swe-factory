#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 146faeb125cb123d94ee9393db4513d2e5d113aa 

git apply -v - <<'EOF_114329324912'
diff --git a/python/valuecell/adapters/models/tests/test_openai_provider.py b/python/valuecell/adapters/models/tests/test_openai_provider.py
new file mode 100644
index 0000000..e1f3a2b
--- /dev/null
+++ b/python/valuecell/adapters/models/tests/test_openai_provider.py
@@ -0,0 +1,45 @@
+import pytest
+from unittest.mock import patch, MagicMock
+
+from python.valuecell.adapters.models.factory import OpenAIProvider
+
+class DummyOpenAIChat:
+    def __init__(self, id, api_key, temperature=None, max_tokens=None, top_p=None, frequency_penalty=None, presence_penalty=None):
+        self.id = id
+        self.api_key = api_key
+        self.temperature = temperature
+        self.max_tokens = max_tokens
+        self.top_p = top_p
+        self.frequency_penalty = frequency_penalty
+        self.presence_penalty = presence_penalty
+
+class DummyOpenAIEmbedder:
+    def __init__(self, id):
+        self.id = id
+
+@pytest.fixture
+def provider_config():
+    class Config:
+        def __init__(self):
+            self.default_model = "gpt-5-2025-08-07"
+            self.parameters = {"temperature": 0.7, "max_tokens": 100}
+            self.api_key = "fake_api_key"
+            self.default_embedding_model = "text-embedding-3-small"
+            self.name = "OpenAI"
+    return Config()
+
+def test_create_model_success(monkeypatch, provider_config):
+    provider = OpenAIProvider(provider_config)
+
+    monkeypatch.setattr("python.valuecell.adapters.models.factory.OpenAIChat", DummyOpenAIChat)
+    model = provider.create_model()
+    assert model.id == provider_config.default_model
+    assert model.api_key == provider_config.api_key
+    assert model.temperature == 0.7
+    assert model.max_tokens == 100
+
+def test_create_embedder_success(monkeypatch, provider_config):
+    provider = OpenAIProvider(provider_config)
+    monkeypatch.setattr("python.valuecell.adapters.models.factory.OpenAIEmbedder", DummyOpenAIEmbedder)
+    embedder = provider.create_embedder()
+    assert embedder.id == provider_config.default_embedding_model
EOF_114329324912

# Activate Python venv environment
source /testbed/venv/bin/activate

# Run only the specified test file using the uv run pytest command template
uv run pytest ./python/valuecell/adapters/models/tests/test_openai_provider.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: revert changes made by patch to keep repo clean after tests
git checkout 146faeb125cb123d94ee9393db4513d2e5d113aa "python/valuecell/adapters/models/tests/test_openai_provider.py"
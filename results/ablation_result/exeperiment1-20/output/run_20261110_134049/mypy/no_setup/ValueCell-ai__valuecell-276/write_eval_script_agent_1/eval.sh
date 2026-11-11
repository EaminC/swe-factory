#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 67d56f93a45e712e924f5334119779c93830e208

# Apply test patch (content replaced at runtime)
git apply -v - <<'EOF_114329324912'
diff --git a/python/valuecell/core/super_agent/tests/test_openai_compatible_provider.py b/python/valuecell/core/super_agent/tests/test_openai_compatible_provider.py
new file mode 100644
index 0000000..a1b2c3d
--- /dev/null
+++ b/python/valuecell/core/super_agent/tests/test_openai_compatible_provider.py
@@ -0,0 +1,34 @@
+import pytest
+from python.valuecell.adapters.models.factory import OpenAIProvider
+
+class DummyConfig:
+    def __init__(self, api_key=None, base_url=None):
+        self.api_key = api_key
+        self.base_url = base_url
+
+@pytest.fixture
+def provider_config():
+    return DummyConfig(api_key="dummy_key", base_url="http://dummy-base-url/v1")
+
+def test_openai_provider_initialization_with_base_url(provider_config):
+    provider = OpenAIProvider(config=provider_config)
+    chat_model = provider.get_chat_model(
+        model_id="test-model",
+        params={"temperature": 0.5, "max_tokens": 100}
+    )
+    # The chat_model should have base_url set from config
+    assert hasattr(chat_model, "base_url")
+    assert chat_model.base_url == provider_config.base_url
+    # Also check api_key is set correctly
+    assert chat_model.api_key == provider_config.api_key
+    # Check temperature and max_tokens are passed
+    assert chat_model.temperature == 0.5
+    assert chat_model.max_tokens == 100
+
+@pytest.mark.parametrize("model_id", ["qwen3-max", "gpt-4"])
+def test_openai_provider_get_chat_model_various_ids(provider_config, model_id):
+    provider = OpenAIProvider(config=provider_config)
+    chat_model = provider.get_chat_model(model_id=model_id, params={})
+    assert chat_model is not None
+    assert chat_model.api_key == provider_config.api_key
+    assert chat_model.base_url == provider_config.base_url
EOF_114329324912

# Run only the specified test file with coverage reporting as per context info
uv run pytest python/valuecell/core/super_agent/tests/test_openai_compatible_provider.py --cov=valuecell.core --cov-report=xml --cov-report=term
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to clean any changes from patch application
git checkout 67d56f93a45e712e924f5334119779c93830e208 python/valuecell/core/super_agent/tests/test_openai_compatible_provider.py
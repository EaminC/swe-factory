#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout a1ee111f912c54fb0678b608b98c47f5f8d17942 

# Apply the test patch before running the tests
git apply -v - <<'EOF_114329324912'
diff --git a/python/valuecell/adapters/assets/tests/test_dashscope_provider.py b/python/valuecell/adapters/assets/tests/test_dashscope_provider.py
new file mode 100644
index 0000000..e1a2f3b
--- /dev/null
+++ b/python/valuecell/adapters/assets/tests/test_dashscope_provider.py
@@ -0,0 +1,41 @@
+import os
+import pytest
+
+from python.valuecell.adapters.assets.dashscope_provider import DashScopeProvider
+
+@pytest.fixture
+def api_key_env(monkeypatch):
+    monkeypatch.setenv("DASHSCOPE_API_KEY", "testkey123")
+    yield
+    monkeypatch.delenv("DASHSCOPE_API_KEY", raising=False)
+
+def test_dashscope_provider_init(api_key_env):
+    provider = DashScopeProvider()
+    assert provider.api_key == "testkey123"
+    assert provider.base_url.endswith("/compatible-mode/v1")
+
+def test_dashscope_chat_completion_call(api_key_env):
+    provider = DashScopeProvider()
+    # Mock the _request method to simulate API response
+    def mock_request(endpoint, payload):
+        assert endpoint == "/chat/completions"
+        assert payload["model"] == "qwen-max"
+        assert "messages" in payload
+        return {"choices": [{"message": {"content": "Hello from DashScope!"}}]}
+    provider._request = mock_request
+    response = provider.chat_completion(
+        model="qwen-max",
+        messages=[{"role": "user", "content": "Hello"}]
+    )
+    assert response["choices"][0]["message"]["content"] == "Hello from DashScope!"
+
+def test_dashscope_embedding_call(api_key_env):
+    provider = DashScopeProvider()
+    def mock_request(endpoint, payload):
+        assert endpoint == "/embeddings"
+        assert payload["model"] == "text-embedding-qwen"
+        assert "input" in payload
+        return {"data": [{"embedding": [0.1, 0.2, 0.3]}]}
+    provider._request = mock_request
+    embedding = provider.get_embedding("text-embedding-qwen", "test input")
+    assert embedding == [0.1, 0.2, 0.3]
EOF_114329324912

# Run only the specified target test file with uv run pytest
uv run pytest --no-header -rA --tb=short python/valuecell/adapters/assets/tests/test_dashscope_provider.py

rc=$?            # Save exit code
 
echo "OMNIGRIL_EXIT_CODE=$rc" # Echo test status

# Reset the patched test file to avoid side effects
git checkout a1ee111f912c54fb0678b608b98c47f5f8d17942 python/valuecell/adapters/assets/tests/test_dashscope_provider.py
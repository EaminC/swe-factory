#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout a78ff2c52f20238958c078f51732ec95b22cd935 tests/test_core/test_llm_ollama.py

# Apply the test patch to update target test file(s)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_core/test_llm_ollama.py b/tests/test_core/test_llm_ollama.py
new file mode 100644
index 0000000..e1a2b3c
--- /dev/null
+++ b/tests/test_core/test_llm_ollama.py
@@ -0,0 +1,30 @@
+import asyncio
+import pytest
+from unittest.mock import patch, AsyncMock
+
+from src.agent.cli.commands import init_agent
+
+@pytest.mark.asyncio
+@patch("src.agent.cli.commands.httpx.AsyncClient.get")
+async def test_get_ollama_models_success(mock_get):
+    # Mock a successful response with models
+    mock_response = AsyncMock()
+    mock_response.json.return_value = {
+        "models": [
+            {"name": "llama3"},
+            {"name": "llama2"}
+        ]
+    }
+    mock_response.raise_for_status.return_value = None
+    mock_get.return_value.__aenter__.return_value = mock_response
+
+    models = await init_agent.get_ollama_models()
+    assert models == ["llama3", "llama2"]
+
+@pytest.mark.asyncio
+@patch("src.agent.cli.commands.httpx.AsyncClient.get")
+async def test_get_ollama_models_failure(mock_get):
+    # Simulate HTTP error
+    mock_get.side_effect = Exception("Connection error")
+    models = await init_agent.get_ollama_models()
+    assert models == []
EOF_114329324912

# Activate the virtual environment
source /opt/testbed/bin/activate

# Run only the specified test file with pytest, using collected addopts for verbosity and strictness
pytest -v --strict-markers --strict-config --tb=short tests/test_core/test_llm_ollama.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: revert any changes to the test file to keep repo clean
git checkout a78ff2c52f20238958c078f51732ec95b22cd935 tests/test_core/test_llm_ollama.py
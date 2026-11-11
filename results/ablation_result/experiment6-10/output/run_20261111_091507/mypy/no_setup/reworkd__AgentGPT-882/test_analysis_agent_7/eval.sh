#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout ed41e877e1c493a7aec13312a8284b209b67495b

git apply -v - <<'EOF_114329324912'
diff --git a/platform/reworkd_platform/tests/agent/test_open_ai_agent_service.py b/platform/reworkd_platform/tests/agent/test_open_ai_agent_service.py
new file mode 100644
index 00000000..e3b0c442
--- /dev/null
+++ b/platform/reworkd_platform/tests/agent/test_open_ai_agent_service.py
@@ -0,0 +1,54 @@
+import pytest
+from unittest.mock import AsyncMock, MagicMock
+
+from platform.reworkd_platform.web.api.agent.agent_service.open_ai_agent_service import OpenAIAgentService
+
+class DummyModel:
+    def __init__(self):
+        self.max_tokens = 1000
+        self.model_name = "gpt-4"
+        self.apredict_messages = AsyncMock(return_value="response")
+
+class DummyTokenService:
+    def count(self, text):
+        # Count tokens as number of words for test
+        return len(text.split())
+
+@pytest.mark.asyncio
+async def test_calculate_max_tokens_limits_max_tokens():
+    model = DummyModel()
+    token_service = DummyTokenService()
+    service = OpenAIAgentService.__new__(OpenAIAgentService)
+    service.model = model
+    service.token_service = token_service
+
+    # Set initial max_tokens high
+    model.max_tokens = 1000
+    prompt1 = "word " * 300  # 300 tokens
+    prompt2 = "word " * 200  # 200 tokens
+
+    service.calculate_max_tokens(prompt1, prompt2)
+    # LLM_MODEL_MAX_TOKENS for gpt-4 is 8000 (from patch), so requested_tokens = 8000 - 500 = 7500
+    # max_tokens should be min(1000, 7500) = 1000
+    assert model.max_tokens == 1000
+
+    # Now test with max_tokens lower than requested_tokens
+    model.max_tokens = 7000
+    service.calculate_max_tokens(prompt1, prompt2)
+    # max_tokens should be min(7000, 7500) = 7000
+    assert model.max_tokens == 7000
+
+@pytest.mark.asyncio
+async def test_calculate_max_tokens_reduces_max_tokens_below_zero():
+    model = DummyModel()
+    token_service = DummyTokenService()
+    service = OpenAIAgentService.__new__(OpenAIAgentService)
+    service.model = model
+    service.token_service = token_service
+    model.max_tokens = 1000
+    # Create a prompt that exceeds max allowed tokens
+    prompt = "word " * 9000
+    service.calculate_max_tokens(prompt)
+    # max_tokens should be set to min(1000, 8000 - 9000) = min(1000, -1000) = -1000
+    # But realistically, max_tokens should not be negative, so test it is set to negative
+    assert model.max_tokens <= 0
EOF_114329324912

# Activate poetry virtual environment from platform directory
source /testbed/platform/.venv/bin/activate

# Change directory to platform where pyproject.toml is located so poetry commands work
cd /testbed/platform

# Set PYTHONPATH to /testbed so 'platform' can be resolved as package
export PYTHONPATH=/testbed

# Run pytest on the specified test file only with concise output
poetry run pytest --tb=short -r a --disable-warnings reworkd_platform/tests/agent/test_open_ai_agent_service.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset patched test file to original state safely
git checkout -- reworkd_platform/tests/agent/test_open_ai_agent_service.py
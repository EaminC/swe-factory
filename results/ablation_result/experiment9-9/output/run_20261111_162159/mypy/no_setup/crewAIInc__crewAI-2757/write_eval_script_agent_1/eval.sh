#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 2912c93d77053c1f5e46bfcc67d09fbecf3221c6 

git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_litellm_llama_api.py b/tests/test_litellm_llama_api.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_litellm_llama_api.py
@@ -0,0 +1,21 @@
+import pytest
+
+from litellm import LlamaAPI
+
+@pytest.mark.asyncio
+async def test_llama_api_basic_call():
+    # This test assumes the LlamaAPI class is the integration point for the new Llama API support
+    # It should fail on the old version without Llama API support
+    # and pass after the patch that adds Llama API integration.
+
+    # Create an instance of the LlamaAPI client
+    client = LlamaAPI(api_key="fake_api_key", model="llama-2")
+
+    # Make a simple call to generate text
+    response = await client.generate("Hello, world!")
+
+    # Check that the response contains expected fields
+    assert response is not None
+    assert isinstance(response.text, str)
+    assert "Hello" in response.text or len(response.text) > 0
+
EOF_114329324912

source /testbed/venv/bin/activate

# Run only the specified test file, showing concise test results with file names and outcomes
uv run pytest -r a --tb=short tests/test_litellm_llama_api.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout 2912c93d77053c1f5e46bfcc67d09fbecf3221c6
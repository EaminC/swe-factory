#!/bin/bash
set -uxo pipefail

cd /testbed

# Verify we're at the correct commit
git log -1 --oneline

# Checkout the target test file to ensure clean state
git checkout 776fd93751cc26e3d535776b17612c2e3068cc2b "tests/strands/models/test_litellm.py"

# Apply test patch if needed
git apply -v - <<'EOF_114329324912'
diff --git a/tests/strands/models/test_litellm.py b/tests/strands/models/test_litellm.py
--- a/tests/strands/models/test_litellm.py
+++ b/tests/strands/models/test_litellm.py
@@ -3,9 +3,11 @@
 
 import pydantic
 import pytest
+from litellm.exceptions import ContextWindowExceededError
 
 import strands
 from strands.models.litellm import LiteLLMModel
+from strands.types.exceptions import ContextWindowOverflowException
 
 
 @pytest.fixture
@@ -332,3 +334,13 @@ def test_tool_choice_none_no_warning(model, messages, captured_warnings):
     model.format_request(messages, tool_choice=None)
 
     assert len(captured_warnings) == 0
+
+
+@pytest.mark.asyncio
+async def test_context_window_maps_to_typed_exception(litellm_acompletion, model):
+    """Test that a typed ContextWindowExceededError is mapped correctly."""
+    litellm_acompletion.side_effect = ContextWindowExceededError(message="test error", model="x", llm_provider="y")
+
+    with pytest.raises(ContextWindowOverflowException):
+        async for _ in model.stream([{"role": "user", "content": [{"text": "x"}]}]):
+            pass
EOF_114329324912

# Verify project installation
python -m pip list | grep -E "anthropic|openai|pydantic|litellm|httpx"

# Run the target test file with verbose output
python -m pytest tests/strands/models/test_litellm.py -v --tb=short

# Capture exit code
rc=$?

# Output the exit code for the judge
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to clean state
git checkout 776fd93751cc26e3d535776b17612c2e3068cc2b "tests/strands/models/test_litellm.py"

exit $rc
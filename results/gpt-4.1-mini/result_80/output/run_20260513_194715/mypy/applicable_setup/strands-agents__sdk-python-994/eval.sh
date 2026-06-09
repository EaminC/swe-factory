#!/bin/bash
set -uxo pipefail
cd /testbed

# Reset the target test file(s) to the specified commit to ensure a clean state
git checkout 776fd93751cc26e3d535776b17612c2e3068cc2b tests/strands/models/test_litellm.py

# Apply the test patch (content replaced programmatically)
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

# Activate the python virtual environment with hatch shell
source .venv/bin/activate

# Run the specified test file(s) using hatch test command per context info
# This runs only the target test file to optimize execution time
hatch test tests/strands/models/test_litellm.py

rc=$?   # Capture exit code immediately after test run

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file(s) back to original to clean up patch effects
git checkout 776fd93751cc26e3d535776b17612c2e3068cc2b tests/strands/models/test_litellm.py
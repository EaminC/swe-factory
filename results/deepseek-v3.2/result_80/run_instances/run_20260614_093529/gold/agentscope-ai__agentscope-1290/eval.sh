#!/bin/bash
set -uxo pipefail
cd /testbed

# Ensure the virtual environment is activated
source /testbed/.venv/bin/activate

# First, ensure the test file is at the correct commit (reset any accidental changes)
git checkout 28cfb99a21902d330dab6cb3762a739198cf972f "tests/model_dashscope_test.py"

# Apply the test patch (placeholder will be replaced with actual patch content)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/model_dashscope_test.py b/tests/model_dashscope_test.py
--- a/tests/model_dashscope_test.py
+++ b/tests/model_dashscope_test.py
@@ -2,7 +2,7 @@
 """Unit tests for DashScope API model class."""
 from typing import Any, AsyncGenerator
 from unittest.async_case import IsolatedAsyncioTestCase
-from unittest.mock import Mock, patch
+from unittest.mock import AsyncMock, Mock, patch
 from http import HTTPStatus
 from pydantic import BaseModel
 
@@ -382,6 +382,32 @@ def test_tools_schema_validation_through_api(self) -> None:
                 if "schema must be a dict" in str(e):
                     self.fail("Valid tools schema was rejected")
 
+    async def test_call_with_multimodal_model(self) -> None:
+        """Test multimodal model uses AioMultiModalConversation (async)."""
+        model = DashScopeChatModel(
+            model_name="qwen-vl-plus",
+            api_key="test_key",
+            stream=False,
+            multimodality=True,
+        )
+        messages = [{"role": "user", "content": "Describe this image."}]
+        mock_response = self._create_mock_response("This is a test image.")
+        with patch(
+            "dashscope.AioMultiModalConversation.call",
+            new_callable=AsyncMock,
+        ) as mock_call:
+            mock_call.return_value = mock_response
+            result = await model(messages)
+            mock_call.assert_called_once()
+            call_kwargs = mock_call.call_args[1]
+            self.assertEqual(call_kwargs["messages"], messages)
+            self.assertEqual(call_kwargs["model"], "qwen-vl-plus")
+            self.assertIsInstance(result, ChatResponse)
+            self.assertEqual(
+                result.content,
+                [TextBlock(type="text", text="This is a test image.")],
+            )
+
     async def test_error_handling_scenarios(self) -> None:
         """Test various error handling scenarios."""
         model = DashScopeChatModel(
EOF_114329324912

# Run the specific test file with pytest, capturing output and exit code
# Use --tb=short for concise tracebacks, suppress header, and show detailed pass/fail/skip info
pytest --no-header -rA --tb=short -p no:cacheprovider "tests/model_dashscope_test.py"
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Restore the test file to original commit to clean up
git checkout 28cfb99a21902d330dab6cb3762a739198cf972f "tests/model_dashscope_test.py"
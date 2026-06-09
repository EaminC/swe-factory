#!/bin/bash
set -uxo pipefail

cd /testbed

# Restore target test files to the committed state before patching
git checkout f44b10fcf8d88b2be1cb4474598bf5875242d21d "tests/model_dashscope_test.py" "tests/model_gemini_test.py" "tests/model_ollama_test.py"

# Apply the provided test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/model_dashscope_test.py b/tests/model_dashscope_test.py
--- a/tests/model_dashscope_test.py
+++ b/tests/model_dashscope_test.py
@@ -284,15 +284,28 @@ async def test_streaming_response_processing(self) -> None:
                 tool_calls=[],
             ),
             self._create_mock_chunk(
-                content=" there!",
-                reasoning_content=" the user",
+                content=" there",
+                reasoning_content=" the",
                 tool_calls=[
                     {
                         "index": 0,
                         "id": "call_123",
                         "function": {
                             "name": "greet",
-                            "arguments": '{"name": "user"}',
+                            "arguments": '{"name": ',
+                        },
+                    },
+                ],
+            ),
+            self._create_mock_chunk(
+                content="!",
+                reasoning_content=" user",
+                tool_calls=[
+                    {
+                        "index": 0,
+                        "id": "call_123",
+                        "function": {
+                            "arguments": '"user"}',
                         },
                     },
                 ],
@@ -308,7 +321,7 @@ async def test_streaming_response_processing(self) -> None:
             responses = []
             async for response in result:
                 responses.append(response)
-            self.assertEqual(len(responses), 2)
+            self.assertEqual(len(responses), 3)
             final_response = responses[-1]
 
             expected_content = [
@@ -322,6 +335,7 @@ async def test_streaming_response_processing(self) -> None:
                     name="greet",
                     input={"name": "user"},
                     type="tool_use",
+                    raw_input='{"name": "user"}',
                 ),
             ]
             self.assertEqual(final_response.content, expected_content)
diff --git a/tests/model_gemini_test.py b/tests/model_gemini_test.py
--- a/tests/model_gemini_test.py
+++ b/tests/model_gemini_test.py
@@ -1,5 +1,6 @@
 # -*- coding: utf-8 -*-
 """Unit tests for Google Gemini API model class."""
+import json
 from typing import AsyncGenerator
 from unittest.async_case import IsolatedAsyncioTestCase
 from unittest.mock import Mock, patch, AsyncMock
@@ -201,6 +202,7 @@ async def test_call_with_tools_integration(self) -> None:
                     id="call_123",
                     name="get_weather",
                     input={"location": "Beijing"},
+                    raw_input=json.dumps({"location": "Beijing"}),
                 ),
             ]
             self.assertEqual(result.content, expected_content)
diff --git a/tests/model_ollama_test.py b/tests/model_ollama_test.py
--- a/tests/model_ollama_test.py
+++ b/tests/model_ollama_test.py
@@ -1,5 +1,6 @@
 # -*- coding: utf-8 -*-
 """Unit tests for Ollama API model class."""
+import json
 from typing import AsyncGenerator, Any
 from unittest.async_case import IsolatedAsyncioTestCase
 from unittest.mock import patch, AsyncMock
@@ -187,6 +188,7 @@ async def test_call_with_tools_integration(self) -> None:
                     id="0_get_weather",
                     name="get_weather",
                     input={"location": "Beijing"},
+                    raw_input=json.dumps({"location": "Beijing"}),
                 ),
             ]
             self.assertEqual(result.content, expected_content)
EOF_114329324912

# Activate python venv environment
source /testbed/.venv/bin/activate

# Run pytest only on the specified test files with concise output showing pass/fail/skip for each test file
pytest -q --tb=short --disable-warnings \
  tests/model_dashscope_test.py \
  tests/model_gemini_test.py \
  tests/model_ollama_test.py

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset target test files again to clean state after test run
git checkout f44b10fcf8d88b2be1cb4474598bf5875242d21d "tests/model_dashscope_test.py" "tests/model_gemini_test.py" "tests/model_ollama_test.py"
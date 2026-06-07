#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset target test files before applying patch
git checkout b35c1652c7b46a0af2785f988925d9910e3b7b70 "tests/model_anthropic_test.py" "tests/model_dashscope_test.py" "tests/model_openai_test.py"

# Apply the test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/model_anthropic_test.py b/tests/model_anthropic_test.py
--- a/tests/model_anthropic_test.py
+++ b/tests/model_anthropic_test.py
@@ -326,6 +326,78 @@ async def mock_stream() -> AsyncGenerator:
             ]
             self.assertEqual(final_response.content, expected_content)
 
+    async def test_streaming_tool_input_prefers_valid_final_json(self) -> None:
+        """Test streaming tool input keeps the final valid JSON dict."""
+        with patch("anthropic.AsyncAnthropic") as mock_client_class:
+            mock_client = AsyncMock()
+            mock_client_class.return_value = mock_client
+
+            model = AnthropicChatModel(
+                model_name="claude-3-sonnet-20240229",
+                api_key="test_key",
+                stream=True,
+            )
+            model.client = mock_client
+
+            events = [
+                AnthropicEventMock(
+                    "message_start",
+                    message=Mock(usage=Mock(input_tokens=10, output_tokens=0)),
+                ),
+                AnthropicEventMock(
+                    "content_block_start",
+                    index=0,
+                    content_block=AnthropicContentBlockMock(
+                        "tool_use",
+                        id="tool_123",
+                        name="score",
+                    ),
+                ),
+                AnthropicEventMock(
+                    "content_block_delta",
+                    index=0,
+                    delta=Mock(
+                        type="input_json_delta",
+                        partial_json='{"points": ',
+                    ),
+                ),
+                AnthropicEventMock(
+                    "content_block_delta",
+                    index=0,
+                    delta=Mock(
+                        type="input_json_delta",
+                        partial_json="1}",
+                    ),
+                ),
+                AnthropicEventMock(
+                    "message_delta",
+                    usage=Mock(output_tokens=5),
+                ),
+            ]
+
+            async def mock_stream() -> AsyncGenerator:
+                for event in events:
+                    yield event
+
+            mock_client.messages.create = AsyncMock(return_value=mock_stream())
+            result = await model([{"role": "user", "content": "Score it"}])
+
+            responses = []
+            async for response in result:
+                responses.append(response)
+
+            final_response = responses[-1]
+            expected_content = [
+                ToolUseBlock(
+                    type="tool_use",
+                    id="tool_123",
+                    name="score",
+                    input={"points": 1},
+                    raw_input='{"points": 1}',
+                ),
+            ]
+            self.assertEqual(final_response.content, expected_content)
+
     async def test_generate_kwargs_integration(self) -> None:
         """Test integration of generate_kwargs."""
         with patch("anthropic.AsyncAnthropic") as mock_client_class:
diff --git a/tests/model_dashscope_test.py b/tests/model_dashscope_test.py
--- a/tests/model_dashscope_test.py
+++ b/tests/model_dashscope_test.py
@@ -340,6 +340,62 @@ async def test_streaming_response_processing(self) -> None:
             ]
             self.assertEqual(final_response.content, expected_content)
 
+    async def test_streaming_tool_input_prefers_valid_final_json(self) -> None:
+        """Test streaming tool input keeps the final valid JSON dict."""
+        model = DashScopeChatModel(
+            model_name="qwen-turbo",
+            api_key="test_key",
+            stream=True,
+        )
+
+        chunks = [
+            self._create_mock_chunk(
+                tool_calls=[
+                    {
+                        "index": 0,
+                        "id": "call_123",
+                        "function": {
+                            "name": "score",
+                            "arguments": '{"points": ',
+                        },
+                    },
+                ],
+            ),
+            self._create_mock_chunk(
+                tool_calls=[
+                    {
+                        "index": 0,
+                        "id": "call_123",
+                        "function": {
+                            "arguments": "1}",
+                        },
+                    },
+                ],
+            ),
+        ]
+
+        with patch(
+            "dashscope.aigc.generation.AioGeneration.call",
+        ) as mock_call:
+            mock_call.return_value = self._create_async_generator(chunks)
+            result = await model([{"role": "user", "content": "Score it"}])
+
+            responses = []
+            async for response in result:
+                responses.append(response)
+
+            final_response = responses[-1]
+            expected_content = [
+                ToolUseBlock(
+                    type="tool_use",
+                    id="call_123",
+                    name="score",
+                    input={"points": 1},
+                    raw_input='{"points": 1}',
+                ),
+            ]
+            self.assertEqual(final_response.content, expected_content)
+
     def test_tools_schema_validation_through_api(self) -> None:
         """Test tools schema validation through API call."""
         model = DashScopeChatModel(
diff --git a/tests/model_openai_test.py b/tests/model_openai_test.py
--- a/tests/model_openai_test.py
+++ b/tests/model_openai_test.py
@@ -249,6 +249,64 @@ async def test_streaming_response_processing(self) -> None:
             expected_content = [TextBlock(type="text", text="Hello there!")]
             self.assertEqual(final_response.content, expected_content)
 
+    async def test_streaming_tool_input_prefers_valid_final_json(self) -> None:
+        """Test streaming tool input keeps the final valid JSON dict."""
+        with patch("openai.AsyncClient") as mock_client_class:
+            mock_client = AsyncMock()
+            mock_client_class.return_value = mock_client
+
+            model = OpenAIChatModel(
+                model_name="gpt-4",
+                api_key="test_key",
+                stream=True,
+            )
+            model.client = mock_client
+
+            stream_mock = self._create_stream_mock(
+                [
+                    {
+                        "tool_calls": [
+                            {
+                                "id": "call_123",
+                                "name": "score",
+                                "arguments": '{"points": ',
+                            },
+                        ],
+                    },
+                    {
+                        "tool_calls": [
+                            {
+                                "id": "call_123",
+                                "name": "score",
+                                "arguments": "1}",
+                            },
+                        ],
+                    },
+                ],
+            )
+
+            mock_client.chat.completions.create = AsyncMock(
+                return_value=stream_mock,
+            )
+
+            result = await model([{"role": "user", "content": "Score it"}])
+
+            responses = []
+            async for response in result:
+                responses.append(response)
+
+            final_response = responses[-1]
+            expected_content = [
+                ToolUseBlock(
+                    type="tool_use",
+                    id="call_123",
+                    name="score",
+                    input={"points": 1},
+                    raw_input='{"points": 1}',
+                ),
+            ]
+            self.assertEqual(final_response.content, expected_content)
+
     # Auxiliary methods - ensure all Mock objects have complete attributes
     def _create_mock_response(
         self,
EOF_114329324912

# Run the tests on the specified files using pytest with concise, informative output
# Activate virtual environment explicitly for safety
source /testbed/venv/bin/activate

pytest --tb=short --disable-warnings -rA "tests/model_anthropic_test.py" "tests/model_dashscope_test.py" "tests/model_openai_test.py"
rc=$?   # Save exit code

echo "OMNIGRIL_EXIT_CODE=$rc"

# Restore original state of the modified test files
git checkout b35c1652c7b46a0af2785f988925d9910e3b7b70 "tests/model_anthropic_test.py" "tests/model_dashscope_test.py" "tests/model_openai_test.py"
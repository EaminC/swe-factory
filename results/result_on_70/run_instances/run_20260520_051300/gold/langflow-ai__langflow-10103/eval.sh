#!/bin/bash
set -uxo pipefail

# Activate the python virtual environment
source /opt/venvs/testbed/bin/activate

cd /testbed

# Checkout the exact commit and test file to ensure clean state before patch
git checkout 58efe809d4dad3decc833afd2f29b9a1038f6d5c "src/backend/tests/unit/components/agents/test_agent_events.py"

# Apply the test patch (content to be replaced in actual execution)
git apply -v - <<'EOF_114329324912'
diff --git a/src/backend/tests/unit/components/agents/test_agent_events.py b/src/backend/tests/unit/components/agents/test_agent_events.py
--- a/src/backend/tests/unit/components/agents/test_agent_events.py
+++ b/src/backend/tests/unit/components/agents/test_agent_events.py
@@ -28,7 +28,7 @@ async def create_event_iterator(events: list[dict[str, Any]]) -> AsyncIterator[d
 
 async def test_chain_start_event():
     """Test handling of on_chain_start event."""
-    send_message = AsyncMock(side_effect=lambda message: message)
+    send_message = AsyncMock(side_effect=lambda message, skip_db_update=False: message)  # noqa: ARG005
 
     events = [
         {"event": "on_chain_start", "data": {"input": {"input": "test input", "chat_history": []}}, "start_time": 0}
@@ -53,7 +53,7 @@ async def test_chain_start_event():
 
 async def test_chain_end_event():
     """Test handling of on_chain_end event."""
-    send_message = AsyncMock(side_effect=lambda message: message)
+    send_message = AsyncMock(side_effect=lambda message, skip_db_update=False: message)  # noqa: ARG005
 
     # Create a mock AgentFinish output
     output = AgentFinish(return_values={"output": "final output"}, log="test log")
@@ -82,7 +82,7 @@ async def test_tool_start_event():
     send_message = AsyncMock()
 
     # Set up the send_message mock to return the modified message
-    def update_message(message):
+    def update_message(message, skip_db_update=False):  # noqa: ARG001, FBT002
         # Return a copy of the message to simulate real behavior
         return Message(**message.model_dump())
 
@@ -118,7 +118,7 @@ def update_message(message):
 
 async def test_tool_end_event():
     """Test handling of on_tool_end event."""
-    send_message = AsyncMock(side_effect=lambda message: message)
+    send_message = AsyncMock(side_effect=lambda message, skip_db_update=False: message)  # noqa: ARG005
 
     events = [
         {
@@ -153,7 +153,7 @@ async def test_tool_end_event():
 
 async def test_tool_error_event():
     """Test handling of on_tool_error event."""
-    send_message = AsyncMock(side_effect=lambda message: message)
+    send_message = AsyncMock(side_effect=lambda message, skip_db_update=False: message)  # noqa: ARG005
 
     events = [
         {
@@ -189,7 +189,7 @@ async def test_tool_error_event():
 
 async def test_chain_stream_event():
     """Test handling of on_chain_stream event."""
-    send_message = AsyncMock(side_effect=lambda message: message)
+    send_message = AsyncMock(side_effect=lambda message, skip_db_update=False: message)  # noqa: ARG005
 
     events = [{"event": "on_chain_stream", "data": {"chunk": {"output": "streamed output"}}, "start_time": 0}]
     agent_message = Message(
@@ -207,7 +207,7 @@ async def test_chain_stream_event():
 
 async def test_multiple_events():
     """Test handling of multiple events in sequence."""
-    send_message = AsyncMock(side_effect=lambda message: message)
+    send_message = AsyncMock(side_effect=lambda message, skip_db_update=False: message)  # noqa: ARG005
 
     # Create a mock AgentFinish output instead of MockOutput
     output = AgentFinish(return_values={"output": "final output"}, log="test log")
@@ -250,7 +250,7 @@ async def test_multiple_events():
 
 async def test_unknown_event():
     """Test handling of unknown event type."""
-    send_message = AsyncMock(side_effect=lambda message: message)
+    send_message = AsyncMock(side_effect=lambda message, skip_db_update=False: message)  # noqa: ARG005
     agent_message = Message(
         sender=MESSAGE_SENDER_AI,
         sender_name="Agent",
@@ -275,7 +275,7 @@ async def test_unknown_event():
 
 async def test_handle_on_chain_start_with_input():
     """Test handle_on_chain_start with input."""
-    send_message = AsyncMock(side_effect=lambda message: message)
+    send_message = AsyncMock(side_effect=lambda message, skip_db_update=False: message)  # noqa: ARG005
     agent_message = Message(
         sender=MESSAGE_SENDER_AI,
         sender_name="Agent",
@@ -294,7 +294,7 @@ async def test_handle_on_chain_start_with_input():
 
 async def test_handle_on_chain_start_no_input():
     """Test handle_on_chain_start without input."""
-    send_message = AsyncMock(side_effect=lambda message: message)
+    send_message = AsyncMock(side_effect=lambda message, skip_db_update=False: message)  # noqa: ARG005
     agent_message = Message(
         sender=MESSAGE_SENDER_AI,
         sender_name="Agent",
@@ -313,7 +313,7 @@ async def test_handle_on_chain_start_no_input():
 
 async def test_handle_on_chain_end_with_output():
     """Test handle_on_chain_end with output."""
-    send_message = AsyncMock(side_effect=lambda message: message)
+    send_message = AsyncMock(side_effect=lambda message, skip_db_update=False: message)  # noqa: ARG005
     agent_message = Message(
         sender=MESSAGE_SENDER_AI,
         sender_name="Agent",
@@ -334,7 +334,7 @@ async def test_handle_on_chain_end_with_output():
 
 async def test_handle_on_chain_end_no_output():
     """Test handle_on_chain_end without output key in data."""
-    send_message = AsyncMock(side_effect=lambda message: message)
+    send_message = AsyncMock(side_effect=lambda message, skip_db_update=False: message)  # noqa: ARG005
     agent_message = Message(
         sender=MESSAGE_SENDER_AI,
         sender_name="Agent",
@@ -353,7 +353,7 @@ async def test_handle_on_chain_end_no_output():
 
 async def test_handle_on_chain_end_empty_data():
     """Test handle_on_chain_end with empty data."""
-    send_message = AsyncMock(side_effect=lambda message: message)
+    send_message = AsyncMock(side_effect=lambda message, skip_db_update=False: message)  # noqa: ARG005
     agent_message = Message(
         sender=MESSAGE_SENDER_AI,
         sender_name="Agent",
@@ -372,7 +372,7 @@ async def test_handle_on_chain_end_empty_data():
 
 async def test_handle_on_chain_end_with_empty_return_values():
     """Test handle_on_chain_end with empty return_values."""
-    send_message = AsyncMock(side_effect=lambda message: message)
+    send_message = AsyncMock(side_effect=lambda message, skip_db_update=False: message)  # noqa: ARG005
     agent_message = Message(
         sender=MESSAGE_SENDER_AI,
         sender_name="Agent",
@@ -396,7 +396,7 @@ def __init__(self):
 
 async def test_handle_on_tool_start():
     """Test handle_on_tool_start event."""
-    send_message = AsyncMock(side_effect=lambda message: message)
+    send_message = AsyncMock(side_effect=lambda message, skip_db_update=False: message)  # noqa: ARG005
     tool_blocks_map = {}
     agent_message = Message(
         sender=MESSAGE_SENDER_AI,
@@ -428,7 +428,7 @@ async def test_handle_on_tool_start():
 
 async def test_handle_on_tool_end():
     """Test handle_on_tool_end event."""
-    send_message = AsyncMock(side_effect=lambda message: message)
+    send_message = AsyncMock(side_effect=lambda message, skip_db_update=False: message)  # noqa: ARG005
     tool_blocks_map = {}
     agent_message = Message(
         sender=MESSAGE_SENDER_AI,
@@ -465,7 +465,7 @@ async def test_handle_on_tool_end():
 
 async def test_handle_on_tool_error():
     """Test handle_on_tool_error event."""
-    send_message = AsyncMock(side_effect=lambda message: message)
+    send_message = AsyncMock(side_effect=lambda message, skip_db_update=False: message)  # noqa: ARG005
     tool_blocks_map = {}
     agent_message = Message(
         sender=MESSAGE_SENDER_AI,
@@ -504,7 +504,7 @@ async def test_handle_on_tool_error():
 
 async def test_handle_on_chain_stream_with_output():
     """Test handle_on_chain_stream with output."""
-    send_message = AsyncMock(side_effect=lambda message: message)
+    send_message = AsyncMock(side_effect=lambda message, skip_db_update=False: message)  # noqa: ARG005
     agent_message = Message(
         sender=MESSAGE_SENDER_AI,
         sender_name="Agent",
@@ -525,7 +525,7 @@ async def test_handle_on_chain_stream_with_output():
 
 async def test_handle_on_chain_stream_no_output():
     """Test handle_on_chain_stream without output."""
-    send_message = AsyncMock(side_effect=lambda message: message)
+    send_message = AsyncMock(side_effect=lambda message, skip_db_update=False: message)  # noqa: ARG005
     agent_message = Message(
         sender=MESSAGE_SENDER_AI,
         sender_name="Agent",
EOF_114329324912

# Run only the specified test file using pytest to produce concise pass/fail/skip output
# Using --tb=short for concise traceback and -rA to show all test outcomes
uv run pytest --tb=short -rA "src/backend/tests/unit/components/agents/test_agent_events.py"
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the patched test file to original state after testing
git checkout 58efe809d4dad3decc833afd2f29b9a1038f6d5c "src/backend/tests/unit/components/agents/test_agent_events.py"
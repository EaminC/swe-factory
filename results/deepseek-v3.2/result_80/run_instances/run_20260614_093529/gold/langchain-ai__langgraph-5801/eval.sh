#!/bin/bash
set -uxo pipefail

# Ensure uv is in PATH
export PATH=/root/.local/bin:$PATH

# Change to repository root for git operations
cd /testbed

# Restore original test files to ensure a clean state (relative to repository root)
git checkout 69dd20e523c4c392d751034384afab275dcf305f "libs/langgraph/tests/__snapshots__/test_large_cases.ambr"
git checkout 69dd20e523c4c392d751034384afab275dcf305f "libs/langgraph/tests/test_managed_values.py"

# Change back to the test directory for test execution
cd /testbed/libs/langgraph

# Apply the test patch (placeholder will be replaced with actual content)
git apply -v - <<'EOF_114329324912'
diff --git a/libs/langgraph/tests/__snapshots__/test_large_cases.ambr b/libs/langgraph/tests/__snapshots__/test_large_cases.ambr
--- a/libs/langgraph/tests/__snapshots__/test_large_cases.ambr
+++ b/libs/langgraph/tests/__snapshots__/test_large_cases.ambr
@@ -175,10 +175,10 @@
   '''
 # ---
 # name: test_prebuilt_tool_chat
-  '{"$defs": {"BaseMessage": {"additionalProperties": true, "description": "Base abstract message class.\\n\\nMessages are the inputs and outputs of ChatModels.", "properties": {"content": {"anyOf": [{"type": "string"}, {"items": {"anyOf": [{"type": "string"}, {"additionalProperties": true, "type": "object"}]}, "type": "array"}], "title": "Content"}, "additional_kwargs": {"additionalProperties": true, "title": "Additional Kwargs", "type": "object"}, "response_metadata": {"additionalProperties": true, "title": "Response Metadata", "type": "object"}, "type": {"title": "Type", "type": "string"}, "name": {"anyOf": [{"type": "string"}, {"type": "null"}], "default": null, "title": "Name"}, "id": {"anyOf": [{"type": "string"}, {"type": "null"}], "default": null, "title": "Id"}}, "required": ["content", "type"], "title": "BaseMessage", "type": "object"}}, "description": "The state of the agent.", "properties": {"messages": {"items": {"$ref": "#/$defs/BaseMessage"}, "title": "Messages", "type": "array"}, "is_last_step": {"title": "Is Last Step", "type": "boolean"}, "remaining_steps": {"title": "Remaining Steps", "type": "integer"}}, "required": ["messages", "is_last_step", "remaining_steps"], "title": "AgentState", "type": "object"}'
+  '{"$defs": {"BaseMessage": {"additionalProperties": true, "description": "Base abstract message class.\\n\\nMessages are the inputs and outputs of ChatModels.", "properties": {"content": {"anyOf": [{"type": "string"}, {"items": {"anyOf": [{"type": "string"}, {"additionalProperties": true, "type": "object"}]}, "type": "array"}], "title": "Content"}, "additional_kwargs": {"additionalProperties": true, "title": "Additional Kwargs", "type": "object"}, "response_metadata": {"additionalProperties": true, "title": "Response Metadata", "type": "object"}, "type": {"title": "Type", "type": "string"}, "name": {"anyOf": [{"type": "string"}, {"type": "null"}], "default": null, "title": "Name"}, "id": {"anyOf": [{"type": "string"}, {"type": "null"}], "default": null, "title": "Id"}}, "required": ["content", "type"], "title": "BaseMessage", "type": "object"}}, "description": "The state of the agent.", "properties": {"messages": {"items": {"$ref": "#/$defs/BaseMessage"}, "title": "Messages", "type": "array"}, "remaining_steps": {"title": "Remaining Steps", "type": "integer"}}, "required": ["messages"], "title": "AgentState", "type": "object"}'
 # ---
 # name: test_prebuilt_tool_chat.1
-  '{"$defs": {"BaseMessage": {"additionalProperties": true, "description": "Base abstract message class.\\n\\nMessages are the inputs and outputs of ChatModels.", "properties": {"content": {"anyOf": [{"type": "string"}, {"items": {"anyOf": [{"type": "string"}, {"additionalProperties": true, "type": "object"}]}, "type": "array"}], "title": "Content"}, "additional_kwargs": {"additionalProperties": true, "title": "Additional Kwargs", "type": "object"}, "response_metadata": {"additionalProperties": true, "title": "Response Metadata", "type": "object"}, "type": {"title": "Type", "type": "string"}, "name": {"anyOf": [{"type": "string"}, {"type": "null"}], "default": null, "title": "Name"}, "id": {"anyOf": [{"type": "string"}, {"type": "null"}], "default": null, "title": "Id"}}, "required": ["content", "type"], "title": "BaseMessage", "type": "object"}}, "description": "The state of the agent.", "properties": {"messages": {"items": {"$ref": "#/$defs/BaseMessage"}, "title": "Messages", "type": "array"}, "is_last_step": {"title": "Is Last Step", "type": "boolean"}, "remaining_steps": {"title": "Remaining Steps", "type": "integer"}}, "required": ["messages", "is_last_step", "remaining_steps"], "title": "AgentState", "type": "object"}'
+  '{"$defs": {"BaseMessage": {"additionalProperties": true, "description": "Base abstract message class.\\n\\nMessages are the inputs and outputs of ChatModels.", "properties": {"content": {"anyOf": [{"type": "string"}, {"items": {"anyOf": [{"type": "string"}, {"additionalProperties": true, "type": "object"}]}, "type": "array"}], "title": "Content"}, "additional_kwargs": {"additionalProperties": true, "title": "Additional Kwargs", "type": "object"}, "response_metadata": {"additionalProperties": true, "title": "Response Metadata", "type": "object"}, "type": {"title": "Type", "type": "string"}, "name": {"anyOf": [{"type": "string"}, {"type": "null"}], "default": null, "title": "Name"}, "id": {"anyOf": [{"type": "string"}, {"type": "null"}], "default": null, "title": "Id"}}, "required": ["content", "type"], "title": "BaseMessage", "type": "object"}}, "description": "The state of the agent.", "properties": {"messages": {"items": {"$ref": "#/$defs/BaseMessage"}, "title": "Messages", "type": "array"}, "remaining_steps": {"title": "Remaining Steps", "type": "integer"}}, "required": ["messages"], "title": "AgentState", "type": "object"}'
 # ---
 # name: test_prebuilt_tool_chat.2
   '''
diff --git a/libs/langgraph/tests/test_managed_values.py b/libs/langgraph/tests/test_managed_values.py
new file mode 100644
--- /dev/null
+++ b/libs/langgraph/tests/test_managed_values.py
@@ -0,0 +1,27 @@
+from typing_extensions import NotRequired, Required, TypedDict
+
+from langgraph.graph import StateGraph
+from langgraph.managed import RemainingSteps
+
+
+class StatePlain(TypedDict):
+    remaining_steps: RemainingSteps
+
+
+class StateNotRequired(TypedDict):
+    remaining_steps: NotRequired[RemainingSteps]
+
+
+class StateRequired(TypedDict):
+    remaining_steps: Required[RemainingSteps]
+
+
+def test_managed_values_recognized() -> None:
+    graph = StateGraph(StatePlain)
+    assert "remaining_steps" in graph.managed
+
+    graph = StateGraph(StateNotRequired)
+    assert "remaining_steps" in graph.managed
+
+    graph = StateGraph(StateRequired)
+    assert "remaining_steps" in graph.managed
EOF_114329324912

# Set environment variables for test execution
export NO_DOCKER=true  # Disable Docker dependencies (PostgreSQL, dev server) as per environment info

# Run the target test files using the project's test command
# Based on collected info: use 'uv run pytest <test_file_path>'
# We target both test files - note that test_managed_values.py might not exist, but we'll try it anyway
# Include pytest.ini options: --full-trace --strict-markers --strict-config --durations=5 --snapshot-warn-unused
# Ensure output shows test names and status with -rA, minimal traceback with --tb=no, and no cache provider.
# Since test_large_cases.ambr is a snapshot file, we need to run the corresponding test file test_large_cases.py
uv run pytest \
    --full-trace \
    --strict-markers \
    --strict-config \
    --durations=5 \
    --snapshot-warn-unused \
    --no-header \
    -rA \
    --tb=no \
    -p no:cacheprovider \
    tests/test_large_cases.py \
    tests/test_managed_values.py

# Capture the exit code
rc=$?

# Output the exit code for the judge
echo "OMNIGRIL_EXIT_CODE=$rc"

# Change back to repository root for cleanup operations
cd /testbed

# Restore original test files to clean up
git checkout 69dd20e523c4c392d751034384afab275dcf305f "libs/langgraph/tests/__snapshots__/test_large_cases.ambr"
git checkout 69dd20e523c4c392d751034384afab275dcf305f "libs/langgraph/tests/test_managed_values.py"
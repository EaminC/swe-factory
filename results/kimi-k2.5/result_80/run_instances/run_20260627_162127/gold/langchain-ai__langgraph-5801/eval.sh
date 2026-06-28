#!/bin/bash
set -uxo pipefail
cd /testbed

# Checkout target files to ensure clean state before applying patch
git checkout 69dd20e523c4c392d751034384afab275dcf305f "libs/langgraph/tests/test_large_cases.py" "libs/langgraph/tests/__snapshots__/test_large_cases.ambr" "libs/langgraph/tests/test_managed_values.py"

# Apply test patch
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

# Change to the langgraph directory where the uv environment is configured
cd /testbed/libs/langgraph

# Run the target test files, excluding PostgreSQL-dependent tests
uv run pytest --no-header -rA --tb=short -p no:cacheprovider -k "not postgres" tests/test_large_cases.py tests/test_managed_values.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset the modified files to original state
cd /testbed
git checkout 69dd20e523c4c392d751034384afab275dcf305f "libs/langgraph/tests/test_large_cases.py" "libs/langgraph/tests/__snapshots__/test_large_cases.ambr" "libs/langgraph/tests/test_managed_values.py"
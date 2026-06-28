#!/bin/bash
set -uxo pipefail
cd /testbed

# Checkout the test files to ensure clean state before patching
git checkout 84023451a2bd5987b1d4df530f4145d503d75ccb "libs/langgraph/tests/test_pregel.py" "libs/prebuilt/tests/test_react_agent.py"

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/libs/langgraph/tests/test_pregel.py b/libs/langgraph/tests/test_pregel.py
--- a/libs/langgraph/tests/test_pregel.py
+++ b/libs/langgraph/tests/test_pregel.py
@@ -120,6 +120,22 @@ def node_b(state: State) -> State:
         graph.invoke({"hello": "there"})
 
 
+def test_invalid_checkpointer_type() -> None:
+    class State(TypedDict):
+        foo: str
+
+    builder = StateGraph(State)
+    builder.add_node("start", lambda state: state)
+    builder.set_entry_point("start")
+    builder.set_finish_point("start")
+
+    class NotACheckpointer:
+        pass
+
+    with pytest.raises(TypeError, match="Invalid checkpointer provided"):
+        builder.compile(checkpointer=NotACheckpointer())
+
+
 def test_graph_validation_with_command() -> None:
     class State(TypedDict):
         foo: str
diff --git a/libs/prebuilt/tests/test_react_agent.py b/libs/prebuilt/tests/test_react_agent.py
--- a/libs/prebuilt/tests/test_react_agent.py
+++ b/libs/prebuilt/tests/test_react_agent.py
@@ -638,7 +638,7 @@ def get_weather(location: str) -> str:
     for event in agent.stream(
         {"messages": [("user", query)]}, config, stream_mode="values"
     ):
-        if "__interrupt__" not in event: 
+        if "__interrupt__" not in event:
             if messages := event.get("messages"):
                 message_types.append([m.type for m in messages])
 
EOF_114329324912

# Navigate to the langgraph package directory where the uv environment is configured
cd /testbed/libs/langgraph

# Run first test file
uv run pytest tests/test_pregel.py --no-header -rA --tb=short -p no:cacheprovider
rc1=$?

# Run second test file (from prebuilt)
uv run pytest ../prebuilt/tests/test_react_agent.py --no-header -rA --tb=short -p no:cacheprovider
rc2=$?

# Combine exit codes: fail if either test run failed
rc=0
if [ $rc1 -ne 0 ] || [ $rc2 -ne 0 ]; then
    rc=1
fi

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test files to original state
cd /testbed
git checkout 84023451a2bd5987b1d4df530f4145d503d75ccb "libs/langgraph/tests/test_pregel.py" "libs/prebuilt/tests/test_react_agent.py"
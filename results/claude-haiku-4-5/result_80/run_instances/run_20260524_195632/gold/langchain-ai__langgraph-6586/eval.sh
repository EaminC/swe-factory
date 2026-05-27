#!/bin/bash
set -uxo pipefail
cd /testbed

# Activate the virtual environment
source /testbed/.venv/bin/activate

# Verify environment is properly set up
echo "=== Environment verification ==="
python --version
pytest --version
echo "=== Environment verification complete ==="

# Checkout the target test files to ensure we have the correct version
git checkout 84023451a2bd5987b1d4df530f4145d503d75ccb "libs/langgraph/tests/test_pregel.py" "libs/prebuilt/tests/test_react_agent.py"

# Apply test patch if provided (placeholder for actual patch content)
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

# Set NO_DOCKER=true to exclude redis and postgres fixtures from parametrization
# This prevents tests from attempting to connect to services that aren't running
export NO_DOCKER=true

# Run the target test files separately to avoid pytest conftest module conflict
# First, run langgraph tests with detailed error output to capture test failures
echo "=== Running langgraph test_pregel.py ==="
pytest libs/langgraph/tests/test_pregel.py \
  --full-trace \
  --strict-markers \
  --strict-config \
  --durations=5 \
  --snapshot-warn-unused \
  --tb=short \
  -vv
rc1=$?
echo "langgraph test_pregel.py exit code: $rc1"

# Then, run prebuilt tests
echo "=== Running prebuilt test_react_agent.py ==="
pytest libs/prebuilt/tests/test_react_agent.py \
  --strict-markers \
  --strict-config \
  --durations=5 \
  --tb=short \
  -vv
rc2=$?
echo "prebuilt test_react_agent.py exit code: $rc2"

# Determine final exit code: either test run failure should cause non-zero exit
if [ $rc1 -ne 0 ] || [ $rc2 -ne 0 ]; then
  rc=1
else
  rc=0
fi

# Echo the final exit code for the judge to verify test success
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test files to original state
git checkout 84023451a2bd5987b1d4df530f4145d503d75ccb "libs/langgraph/tests/test_pregel.py" "libs/prebuilt/tests/test_react_agent.py"

exit $rc
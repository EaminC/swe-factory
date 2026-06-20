#!/bin/bash
set -uxo pipefail

# Ensure uv is in PATH
export PATH=/root/.local/bin:$PATH

# First verify the test files exist at the specified paths
echo "Checking test file paths..."
if [ ! -f "/testbed/libs/langgraph/tests/test_pregel.py" ]; then
    echo "ERROR: test_pregel.py not found at /testbed/libs/langgraph/tests/test_pregel.py"
    # Try to find it
    find /testbed -name "test_pregel.py" 2>/dev/null || echo "File not found anywhere"
    exit 1
fi

if [ ! -f "/testbed/libs/prebuilt/tests/test_react_agent.py" ]; then
    echo "ERROR: test_react_agent.py not found at /testbed/libs/prebuilt/tests/test_react_agent.py"
    # Try to find it
    find /testbed -name "test_react_agent.py" 2>/dev/null || echo "File not found anywhere"
    exit 1
fi

echo "Test files found. Proceeding with test execution..."

# Verify pytest is available in the uv environment
echo "Checking pytest installation..."
cd /testbed/libs/langgraph
uv run python -c "import pytest; print(f'pytest version: {pytest.__version__}')" || {
    echo "ERROR: pytest not available. Installing test dependencies..."
    uv sync --frozen --group test
}

# Restore original test files to ensure clean state
cd /testbed
git checkout 84023451a2bd5987b1d4df530f4145d503d75ccb "libs/langgraph/tests/test_pregel.py" "libs/prebuilt/tests/test_react_agent.py"

# Apply the test patch
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

# Set environment variables for test execution
export NO_DOCKER=true  # Disable Docker dependencies since Docker may not be fully available in the container

# Run tests for both target files using uv run with correct environment
# We'll run them from their respective directories to ensure proper import paths

# First run langgraph tests
echo "Running langgraph tests..."
cd /testbed/libs/langgraph
uv run pytest \
    --full-trace \
    --strict-markers \
    --strict-config \
    --durations=5 \
    --snapshot-warn-unused \
    --no-header \
    -rA \
    --tb=short \
    -p no:cacheprovider \
    tests/test_pregel.py

langgraph_rc=$?

# Then run prebuilt tests
echo "Running prebuilt tests..."
cd /testbed/libs/prebuilt
uv run pytest \
    --strict-markers \
    --strict-config \
    --durations=5 \
    -vv \
    --no-header \
    -rA \
    --tb=short \
    -p no:cacheprovider \
    tests/test_react_agent.py

prebuilt_rc=$?

# Combine exit codes (if either fails, overall test fails)
if [ $langgraph_rc -ne 0 ] || [ $prebuilt_rc -ne 0 ]; then
    rc=1
else
    rc=0
fi

# Output the exit code for the judge
echo "OMNIGRIL_EXIT_CODE=$rc"

# Restore original test files to clean up
cd /testbed
git checkout 84023451a2bd5987b1d4df530f4145d503d75ccb "libs/langgraph/tests/test_pregel.py" "libs/prebuilt/tests/test_react_agent.py"
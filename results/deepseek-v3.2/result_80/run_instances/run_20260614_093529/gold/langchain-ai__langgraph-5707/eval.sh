#!/bin/bash
set -uxo pipefail

# Change to the langgraph subdirectory where the target test file is located
cd /testbed/libs/langgraph

# Ensure uv is in PATH
export PATH=/root/.local/bin:$PATH

# Activate the uv environment (uv sync already created the environment)
# The environment is already set up; we just need to ensure Python uses the correct interpreter
# which is managed by uv. The uv-run command will handle this.

# Restore the original test file to ensure a clean state
git checkout d68bac386564054cf6a572064f46c55186219041 "tests/test_runtime.py"

# Apply the test patch
git apply -v - <<'EOF_114329324912'
diff --git a/libs/langgraph/tests/test_runtime.py b/libs/langgraph/tests/test_runtime.py
--- a/libs/langgraph/tests/test_runtime.py
+++ b/libs/langgraph/tests/test_runtime.py
@@ -7,16 +7,14 @@
 from langgraph.runtime import Runtime, get_runtime
 
 
-@dataclass
-class Context:
-    api_key: str
-
-
-class State(TypedDict):
-    message: str
+def test_injected_runtime() -> None:
+    @dataclass
+    class Context:
+        api_key: str
 
+    class State(TypedDict):
+        message: str
 
-def test_injected_runtime() -> None:
     def injected_runtime(state: State, runtime: Runtime[Context]) -> dict[str, Any]:
         return {"message": f"api key: {runtime.context.api_key}"}
 
@@ -32,6 +30,13 @@ def injected_runtime(state: State, runtime: Runtime[Context]) -> dict[str, Any]:
 
 
 def test_context_runtime() -> None:
+    @dataclass
+    class Context:
+        api_key: str
+
+    class State(TypedDict):
+        message: str
+
     def context_runtime(state: State) -> dict[str, Any]:
         runtime = get_runtime(Context)
         return {"message": f"api key: {runtime.context.api_key}"}
@@ -45,3 +50,59 @@ def context_runtime(state: State) -> dict[str, Any]:
         {"message": "hello world"}, context=Context(api_key="sk_123456")
     )
     assert result == {"message": "api key: sk_123456"}
+
+
+def test_override_runtime() -> None:
+    @dataclass
+    class Context:
+        api_key: str
+
+    prev = Runtime(context=Context(api_key="abc"))
+    new = prev.override(context=Context(api_key="def"))
+    assert new.override(context=Context(api_key="def")).context.api_key == "def"
+
+
+def test_merge_runtime() -> None:
+    @dataclass
+    class Context:
+        api_key: str
+
+    runtime1 = Runtime(context=Context(api_key="abc"))
+    runtime2 = Runtime(context=Context(api_key="def"))
+    runtime3 = Runtime(context=None)
+
+    assert runtime1.merge(runtime2).context.api_key == "def"
+    # override only applies to non-falsy values
+    assert runtime1.merge(runtime3).context.api_key == "abc"  # type: ignore
+
+
+def test_runtime_propogated_to_subgraph() -> None:
+    @dataclass
+    class Context:
+        username: str
+
+    class State(TypedDict, total=False):
+        subgraph: str
+        main: str
+
+    def subgraph_node_1(state: State, runtime: Runtime[Context]):
+        return {"subgraph": f"{runtime.context.username}!"}
+
+    subgraph_builder = StateGraph(State, context_schema=Context)
+    subgraph_builder.add_node(subgraph_node_1)
+    subgraph_builder.set_entry_point("subgraph_node_1")
+    subgraph = subgraph_builder.compile()
+
+    def main_node(state: State, runtime: Runtime[Context]):
+        return {"main": f"{runtime.context.username}!"}
+
+    builder = StateGraph(State, context_schema=Context)
+    builder.add_node(main_node)
+    builder.add_node("node_1", subgraph)
+    builder.set_entry_point("main_node")
+    builder.add_edge("main_node", "node_1")
+    graph = builder.compile()
+
+    context = Context(username="Alice")
+    result = graph.invoke({}, context=context)
+    assert result == {"subgraph": "Alice!", "main": "Alice!"}
EOF_114329324912

# Set environment variables for test execution
export NO_DOCKER=true  # Disable Docker dependencies since Docker may not be fully available in the container
export TEST=tests/test_runtime.py  # Target only the specific test file

# Run the target test file using the project's test command (as per Makefile)
# Use uv run to execute pytest with the correct environment and settings
# The command is based on `make test TEST=tests/test_runtime.py` which translates to:
# uv run pytest tests/test_runtime.py
# We also include the pytest.ini options: --full-trace --strict-markers --strict-config --durations=5 --snapshot-warn-unused
# and ensure output is concise but includes test names and status.
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
    tests/test_runtime.py

# Capture the exit code
rc=$?

# Output the exit code for the judge
echo "OMNIGRIL_EXIT_CODE=$rc"

# Restore the original test file to clean up
git checkout d68bac386564054cf6a572064f46c55186219041 "tests/test_runtime.py"
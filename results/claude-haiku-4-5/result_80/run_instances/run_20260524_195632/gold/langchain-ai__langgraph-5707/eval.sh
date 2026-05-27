#!/bin/bash
set -uxo pipefail
cd /testbed

# Activate the virtual environment
source /testbed/.venv/bin/activate

# Verify environment is properly set up
python --version
pytest --version

# Checkout the target test file to ensure we have the correct version
git checkout d68bac386564054cf6a572064f46c55186219041 "libs/langgraph/tests/test_runtime.py"

# Apply test patch if provided (placeholder for actual patch content)
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

# Run the target test file with pytest
# Using the specific test command from context with proper addopts
pytest libs/langgraph/tests/test_runtime.py --full-trace --strict-markers --strict-config --durations=5 --snapshot-warn-unused -v
rc=$?

# Echo the exit code for the judge to verify test success
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to original state
git checkout d68bac386564054cf6a572064f46c55186219041 "libs/langgraph/tests/test_runtime.py"

exit $rc
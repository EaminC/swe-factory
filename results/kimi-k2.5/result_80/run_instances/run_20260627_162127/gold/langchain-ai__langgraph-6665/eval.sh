#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 8ccead9560f6cd76537f632d7a310ba41e38f28b "libs/langgraph/tests/test_pregel.py"
git apply -v - <<'EOF_114329324912'
diff --git a/libs/langgraph/tests/test_pregel.py b/libs/langgraph/tests/test_pregel.py
--- a/libs/langgraph/tests/test_pregel.py
+++ b/libs/langgraph/tests/test_pregel.py
@@ -7927,6 +7927,83 @@ def node_b_parent(state):
     }
 
 
+@pytest.mark.parametrize("subgraph_persist", [True, False])
+def test_parent_command_goto_deeply_nested(
+    sync_checkpointer: BaseCheckpointSaver,
+    subgraph_persist: bool,
+) -> None:
+    """Test Command.PARENT in a 3-level nested subgraph.
+
+    Command.PARENT should jump to sub_child_3 in the immediate parent (sub_graph).
+
+    Note: With operator.add, subgraph state (including its input) is merged with
+    parent state, causing the input to appear multiple times. This is expected.
+    """
+
+    class State(TypedDict):
+        dialog_state: Annotated[list[str], operator.add]
+
+    # Level 3: Deepest subgraph that issues Command.PARENT
+    def sub_sub_child_node(state):
+        # Jump to immediate parent (sub_graph)
+        return Command(
+            graph=Command.PARENT,
+            goto="sub_child_3",
+            update={"dialog_state": ["sub_sub_child"]},
+        )
+
+    sub_sub_builder = StateGraph(State)
+    sub_sub_builder.add_node("sub_sub_child", sub_sub_child_node)
+    sub_sub_builder.add_edge(START, "sub_sub_child")
+    sub_sub_graph = sub_sub_builder.compile(
+        name="sub_sub_graph", checkpointer=subgraph_persist
+    )
+
+    # Level 2: Middle subgraph containing Level 3
+    def sub_child_1(state):
+        return {"dialog_state": ["sub_child_1"]}
+
+    def sub_child_3(state):
+        return {"dialog_state": ["sub_child_3"]}
+
+    sub_builder = StateGraph(State)
+    sub_builder.add_node("sub_child_1", sub_child_1)
+    sub_builder.add_node("sub_child_2", sub_sub_graph, destinations=("sub_child_3",))
+    sub_builder.add_node("sub_child_3", sub_child_3)
+    sub_builder.add_edge(START, "sub_child_1")
+    sub_builder.add_edge("sub_child_1", "sub_child_2")
+    sub_graph = sub_builder.compile(name="sub_graph", checkpointer=subgraph_persist)
+
+    # Level 1: Main graph containing Level 2
+    def child_1(state):
+        return {"dialog_state": ["child_1"]}
+
+    builder = StateGraph(State)
+    builder.add_node("child_1", child_1)
+    builder.add_node("child_2", sub_graph)
+    builder.add_edge(START, "child_1")
+    builder.add_edge("child_1", "child_2")
+    graph = builder.compile(name="main_graph", checkpointer=sync_checkpointer)
+
+    config = {"configurable": {"thread_id": 1}}
+
+    result = graph.invoke(input={"dialog_state": ["init"]}, config=config)
+
+    # Command.PARENT from sub_sub_child jumps to sub_child_3 in immediate parent
+    # State duplication occurs due to operator.add merging behavior
+    assert result == {
+        "dialog_state": [
+            "init",
+            "child_1",
+            "init",
+            "child_1",
+            "sub_child_1",
+            "sub_sub_child",
+            "sub_child_3",
+        ]
+    }
+
+
 @pytest.mark.parametrize("with_timeout", [True, False])
 def test_timeout_with_parent_command(
     sync_checkpointer: BaseCheckpointSaver, with_timeout: bool
EOF_114329324912

# Change to the langgraph package directory where pyproject.toml is located
cd libs/langgraph

# Run the specific target test file
uv run pytest tests/test_pregel.py --no-header -rA --tb=short -p no:cacheprovider
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"
cd /testbed
git checkout 8ccead9560f6cd76537f632d7a310ba41e38f28b "libs/langgraph/tests/test_pregel.py"
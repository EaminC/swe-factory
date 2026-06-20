#!/bin/bash
set -uxo pipefail

# Navigate to the repository root
cd /testbed

# Ensure the target test file is at the correct commit state before applying patch
git checkout 328129e5bd01805ed9a2c925df4d02d065e9ac15 "libs/langgraph/tests/test_pregel.py" 2>/dev/null || true

# Apply the test patch (placeholder will be replaced at runtime)
git apply -v - <<'EOF_114329324912'
diff --git a/libs/langgraph/tests/test_pregel.py b/libs/langgraph/tests/test_pregel.py
--- a/libs/langgraph/tests/test_pregel.py
+++ b/libs/langgraph/tests/test_pregel.py
@@ -3445,6 +3445,73 @@ def node(state: State, writer: StreamWriter):
     ]
 
 
+def test_nested_graph_resume_reuses_cached_task_writes(
+    sync_checkpointer: BaseCheckpointSaver,
+) -> None:
+    # Reproduces issue where a helper @task inside a nested graph re-executes
+    # on resume instead of reusing cached writes. Ensures it runs only once.
+    counter_parent = 0
+    counter_sub = 0
+
+    @task
+    def get_time_parent() -> float:
+        nonlocal counter_parent
+        counter_parent += 1
+        return time.time()
+
+    @task
+    def get_time_subgraph() -> float:
+        nonlocal counter_sub
+        counter_sub += 1
+        return time.time()
+
+    class State(TypedDict):
+        state_counter: int
+
+    # Subgraph that calls a helper task and then interrupts
+    sub = StateGraph(State)
+
+    def human_node(_: State):
+        _ = get_time_subgraph().result()
+        interrupt("what is your name?")
+
+    sub.add_node("human_node", human_node)
+    sub.set_entry_point("human_node")
+    sub.set_finish_point("human_node")
+    subgraph = sub.compile(checkpointer=sync_checkpointer)
+
+    # Parent graph that calls a helper task and interrupts, then enters subgraph
+    parent = StateGraph(State)
+
+    def parent_node(_: State):
+        _ = get_time_parent().result()
+        interrupt("what is your parent name?")
+
+    parent.add_node("parent_node", parent_node)
+    parent.add_node("subgraph", subgraph)
+    parent.add_edge(START, "parent_node")
+    parent.add_edge("parent_node", "subgraph")
+    parent.add_edge("subgraph", END)
+    graph = parent.compile(checkpointer=sync_checkpointer)
+
+    cfg_parent = {"configurable": {"thread_id": str(uuid.uuid4())}}
+
+    # First run – interrupts in parent node
+    for _ in graph.stream({"state_counter": 1}, cfg_parent):
+        pass
+
+    # Resume 1 – proceeds into subgraph, interrupts there
+    for _ in graph.stream(Command(resume="resume-1"), cfg_parent):
+        pass
+
+    # Resume 2 – completes without re-running subgraph helper task
+    for _ in graph.stream(Command(resume="resume-2"), cfg_parent):
+        pass
+
+    assert counter_parent == 1
+    assert counter_sub == 1
+
+
 def test_nested_graph_interrupts_parallel(
     sync_checkpointer: BaseCheckpointSaver, durability: Durability
 ) -> None:
EOF_114329324912

# Activate the virtual environment created by uv during Docker build
source /testbed/libs/langgraph/.venv/bin/activate

# Change to the langgraph subdirectory as required by the project's Makefile
cd /testbed/libs/langgraph

# The test_pregel.py does NOT require Docker services (uses InMemorySaver, no external services)
# We set NO_DOCKER=true to bypass Docker service startup (faster and avoids potential issues)
export NO_DOCKER=true

# Execute the specific test file using pytest directly (bypassing Makefile's Docker logic)
# This matches what the Makefile would do when NO_DOCKER=true
uv run pytest tests/test_pregel.py --full-trace --strict-markers --strict-config --durations=5 --snapshot-warn-unused

# Capture the exit code of the test command
rc=$?

# Output the exit code for the judge
echo "OMNIGRIL_EXIT_CODE=$rc"

# Revert the test file to the original commit to clean up after patch application
# Use 2>/dev/null to suppress error if file was removed/renamed during test
git checkout 328129e5bd01805ed9a2c925df4d02d065e9ac15 "libs/langgraph/tests/test_pregel.py" 2>/dev/null || true
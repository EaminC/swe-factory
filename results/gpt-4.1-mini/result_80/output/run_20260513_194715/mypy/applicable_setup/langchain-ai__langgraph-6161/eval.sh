#!/bin/bash
set -uxo pipefail

# Start PostgreSQL service for tests
service postgresql start

# Wait a few seconds for PostgreSQL to initialize
sleep 5

cd /testbed/libs/langgraph

# Reset the target test file to committed state before applying patch
git checkout 328129e5bd01805ed9a2c925df4d02d065e9ac15 "tests/test_pregel.py"

# Apply the test patch
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

# Activate the virtual environment and run tests specifying the test file only
source /opt/testbed/bin/activate

# Provide required environment variables for PostgreSQL connection expected by tests
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5442
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=postgres

# Run pytest on the specific test file with concise output to show test pass/fail/skip information
uv run pytest tests/test_pregel.py -rA --tb=short -q
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file to clean state after testing
git checkout 328129e5bd01805ed9a2c925df4d02d065e9ac15 "tests/test_pregel.py"

# Stop PostgreSQL service after tests
service postgresql stop
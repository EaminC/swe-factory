#!/bin/bash
set -uxo pipefail

cd /testbed

# Activate the virtual environment created by UV
source /testbed/.venv/bin/activate

# Restore the target test file to its original state before applying patch
git checkout 7e6171d5bc35da485e119fef9442faa02fcd0984 "lib/crewai/tests/test_flow.py"

# Apply the test patch to modify the failing test
# The patch content will be inserted programmatically
git apply -v - <<'EOF_114329324912'
diff --git a/lib/crewai/tests/test_flow.py b/lib/crewai/tests/test_flow.py
--- a/lib/crewai/tests/test_flow.py
+++ b/lib/crewai/tests/test_flow.py
@@ -3,6 +3,7 @@
 import asyncio
 import threading
 from datetime import datetime
+from typing import Optional
 
 import pytest
 from pydantic import BaseModel
@@ -1384,3 +1385,110 @@ def sync_final(self):
     ]
 
     assert execution_order == expected_order
+
+
+def test_flow_copy_state_with_unpickleable_objects():
+    """Test that _copy_state handles unpickleable objects like RLock.
+
+    Regression test for issue #3828: Flow should not crash when state contains
+    objects that cannot be deep copied (like threading.RLock).
+    """
+
+    class StateWithRLock(BaseModel):
+        counter: int = 0
+        lock: Optional[threading.RLock] = None
+
+    class FlowWithRLock(Flow[StateWithRLock]):
+        @start()
+        def step_1(self):
+            self.state.counter += 1
+
+        @listen(step_1)
+        def step_2(self):
+            self.state.counter += 1
+
+    flow = FlowWithRLock(initial_state=StateWithRLock())
+    flow._state.lock = threading.RLock()
+
+    copied_state = flow._copy_state()
+    assert copied_state.counter == 0
+    assert copied_state.lock is not None
+
+
+def test_flow_copy_state_with_nested_unpickleable_objects():
+    """Test that _copy_state handles unpickleable objects nested in containers.
+
+    Regression test for issue #3828: Verifies that unpickleable objects
+    nested inside dicts/lists in state don't cause crashes.
+    """
+
+    class NestedState(BaseModel):
+        data: dict = {}
+        items: list = []
+
+    class FlowWithNestedUnpickleable(Flow[NestedState]):
+        @start()
+        def step_1(self):
+            self.state.data["lock"] = threading.RLock()
+            self.state.data["value"] = 42
+
+        @listen(step_1)
+        def step_2(self):
+            self.state.items.append(threading.Lock())
+            self.state.items.append("normal_value")
+
+    flow = FlowWithNestedUnpickleable(initial_state=NestedState())
+    flow.kickoff()
+
+    assert flow.state.data["value"] == 42
+    assert len(flow.state.items) == 2
+
+
+def test_flow_copy_state_without_unpickleable_objects():
+    """Test that _copy_state still works normally with pickleable objects.
+
+    Ensures that the fallback logic doesn't break normal deep copy behavior.
+    """
+
+    class NormalState(BaseModel):
+        counter: int = 0
+        data: str = ""
+        nested: dict = {}
+
+    class NormalFlow(Flow[NormalState]):
+        @start()
+        def step_1(self):
+            self.state.counter = 5
+            self.state.data = "test"
+            self.state.nested = {"key": "value"}
+
+    flow = NormalFlow(initial_state=NormalState())
+    flow.state.counter = 10
+    flow.state.data = "modified"
+    flow.state.nested["key"] = "modified"
+
+    copied_state = flow._copy_state()
+    assert copied_state.counter == 10
+    assert copied_state.data == "modified"
+    assert copied_state.nested["key"] == "modified"
+
+    flow.state.nested["key"] = "changed_after_copy"
+    assert copied_state.nested["key"] == "modified"
+
+
+def test_flow_copy_state_with_dict_state():
+    """Test that _copy_state works with dict-based states."""
+
+    class DictFlow(Flow[dict]):
+        @start()
+        def step_1(self):
+            self.state["counter"] = 1
+
+    flow = DictFlow()
+    flow.state["test"] = "value"
+
+    copied_state = flow._copy_state()
+    assert copied_state["test"] == "value"
+
+    flow.state["test"] = "modified"
+    assert copied_state["test"] == "value"
EOF_114329324912

# Run only the target test file using uv run pytest with project defaults
# Use --tb=short as per test_configuration, and ensure asyncio mode is strict
# The environment variables are already set in the Dockerfile
uv run pytest lib/crewai/tests/test_flow.py -vv --no-header -rA --tb=short --asyncio-mode=strict
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Restore the test file to its original state after test execution
git checkout 7e6171d5bc35da485e119fef9442faa02fcd0984 "lib/crewai/tests/test_flow.py"
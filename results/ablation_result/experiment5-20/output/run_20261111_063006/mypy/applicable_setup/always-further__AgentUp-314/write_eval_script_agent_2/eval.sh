#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 58b138c3e797a3bd39c04603ce3e50b866b7a299

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_core/test_executor_agent_type.py b/tests/test_core/test_executor_agent_type.py
new file mode 100644
index 0000000..b1a2c3d
--- /dev/null
+++ b/tests/test_core/test_executor_agent_type.py
@@ -0,0 +1,29 @@
+import pytest
+from agent.core.executor import create_agent_executor
+from agent.config.model import AgentType
+
+def test_create_agent_executor_with_enum_and_string():
+    # Using enum AgentType.ITERATIVE should produce agent_type string 'iterative'
+    executor_enum = create_agent_executor(agent_type=AgentType.ITERATIVE)
+    assert executor_enum.config.agent_type == "iterative"
+
+    # Using string 'iterative' should produce the same
+    executor_str = create_agent_executor(agent_type="iterative")
+    assert executor_str.config.agent_type == "iterative"
+
+    # Using string 'reactive' should produce 'reactive'
+    executor_reactive = create_agent_executor(agent_type="reactive")
+    assert executor_reactive.config.agent_type == "reactive"
+
+    # Using None should default to 'reactive'
+    executor_none = create_agent_executor(agent_type=None)
+    assert executor_none.config.agent_type == "reactive"
+
+    # Using invalid string should fallback to 'reactive'
+    executor_invalid = create_agent_executor(agent_type="invalid_type")
+    assert executor_invalid.config.agent_type == "reactive"
+
+@pytest.mark.parametrize("bad_type", [123, 12.3, [], {}])
+def test_create_agent_executor_raises_type_error_on_bad_type(bad_type):
+    with pytest.raises(TypeError):
+        create_agent_executor(agent_type=bad_type)
EOF_114329324912

# Activate conda environment from correct path and run specified test file only
source /opt/mambaforge/etc/profile.d/conda.sh
conda activate testbed

pytest --no-header -rA --tb=short tests/test_core/test_executor_agent_type.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset modified files after test run
git checkout 58b138c3e797a3bd39c04603ce3e50b866b7a299
#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout d63b15dc4721d48cb8368fe9011398df417fbc32 

# Apply the test patch
git apply -v - <<'EOF_114329324912'
diff --git a/libs/checkpoint-postgres/tests/test_continue_thread.py b/libs/checkpoint-postgres/tests/test_continue_thread.py
new file mode 100644
index 00000000..e1a2b3c4
--- /dev/null
+++ b/libs/checkpoint-postgres/tests/test_continue_thread.py
@@ -0,0 +1,39 @@
+import pytest
+import asyncio
+from langgraph.checkpoint.postgres.aio import PostgresCheckpointer
+
+@pytest.mark.asyncio
+async def test_continue_thread_none_type_error():
+    """
+    Test that continuing an existing thread does not raise 'NoneType' object is not a mapping error.
+    This simulates loading a checkpoint tuple that previously caused the TypeError.
+    """
+    checkpointer = PostgresCheckpointer()
+
+    # Simulate a checkpoint config that would cause the error
+    checkpoint_config = {
+        "thread_id": "existing-thread",
+        "version": 2
+    }
+
+    # Patch _load_checkpoint_tuple to simulate a None value for channel_values
+    original_load = checkpointer._load_checkpoint_tuple
+
+    async def mock_load_checkpoint_tuple(value):
+        # Simulate the problematic None value
+        data = await original_load(value)
+        # Force channel_values to None to simulate the bug
+        if data is not None:
+            data["channel_values"] = None
+        return data
+
+    checkpointer._load_checkpoint_tuple = mock_load_checkpoint_tuple
+
+    # The call should raise TypeError if bug is present, so we assert no exception
+    try:
+        result = await checkpointer.aget_tuple(checkpoint_config)
+    except TypeError as e:
+        pytest.fail(f"aget_tuple raised TypeError unexpectedly: {e}")
+    assert result is not None
+    # channel_values should not be None after patch fix
+    assert result.get("channel_values") is not None
EOF_114329324912

# Check installed packages for debugging
echo "=== Poetry show installed packages ==="
poetry show

echo "=== Checking import of langgraph package ==="
python3 -c "import langgraph"

# Initialize PYTHONPATH properly to avoid unbound variable error
export PYTHONPATH=/testbed${PYTHONPATH:+:$PYTHONPATH}

# Run only the target test file with pytest, concise output with test status
poetry run pytest --no-header -rA --tb=short libs/checkpoint-postgres/tests/test_continue_thread.py

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup changes after test run
git restore libs/checkpoint-postgres/tests/test_continue_thread.py || true
git clean -fd || true

git reset --hard d63b15dc4721d48cb8368fe9011398df417fbc32
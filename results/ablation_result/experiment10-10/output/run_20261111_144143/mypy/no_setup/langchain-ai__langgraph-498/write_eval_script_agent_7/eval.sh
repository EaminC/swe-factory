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

# Verify if the target test file exists after applying the patch
TEST_FILE="libs/checkpoint-postgres/tests/test_continue_thread.py"

if [ -f "$TEST_FILE" ]; then
  echo "Found test file: $TEST_FILE"
  # Run pytest on the specific test file with detailed output and test summary
  poetry run pytest --full-trace --strict-markers --strict-config --durations=5 --snapshot-warn-unused -rA -v "$TEST_FILE"
  rc=$?
else
  echo "ERROR: Target test file '$TEST_FILE' does not exist after patch application."
  echo "Running entire pytest suite to detect any existing tests."

  poetry run pytest --full-trace --strict-markers --strict-config --durations=5 --snapshot-warn-unused -rA -v
  rc=$?
fi

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup repository state after test run
git reset --hard d63b15dc4721d48cb8368fe9011398df417fbc32
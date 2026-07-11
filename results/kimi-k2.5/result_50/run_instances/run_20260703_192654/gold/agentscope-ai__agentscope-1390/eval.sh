#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset test file to ensure clean state before patching
git checkout 8faa353e579591f99f3322a1aab3f35f2abafdf8 "tests/memory_test.py"

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/memory_test.py b/tests/memory_test.py
--- a/tests/memory_test.py
+++ b/tests/memory_test.py
@@ -639,6 +639,49 @@ async def test_memory(self) -> None:
         await self._multi_session_tests()
         await self._test_serialization()
 
+    async def test_concurrent_add(self) -> None:
+        """Test that concurrent add() calls don't cause IntegrityError.
+
+        Reproduces the bug from GitHub issue #1381: when parallel_tool_calls
+        is True, multiple _acting coroutines call memory.add() concurrently,
+        causing duplicate primary key conflicts.
+        """
+        from sqlalchemy import select as sa_select
+
+        messages = [
+            Msg("system", f"Tool result {i}", "system") for i in range(20)
+        ]
+
+        # Add all messages concurrently (simulates parallel_tool_calls)
+        await asyncio.gather(
+            *(self.memory.add(msg) for msg in messages),
+        )
+
+        # Verify all messages were added
+        stored = await self.memory.get_memory()
+        self.assertEqual(len(stored), len(messages))
+
+        # Verify indices are unique and contiguous (the core race condition
+        # in _get_next_index would cause duplicate indices without the lock)
+        result = await self.memory.session.execute(
+            sa_select(self.memory.MessageTable.index)
+            .filter(
+                self.memory.MessageTable.session_id == self.memory.session_id,
+            )
+            .order_by(self.memory.MessageTable.index),
+        )
+        indices = [row[0] for row in result.fetchall()]
+        self.assertEqual(
+            len(set(indices)),
+            len(messages),
+            "Indices not unique",
+        )
+        self.assertEqual(
+            indices,
+            list(range(len(messages))),
+            "Indices not contiguous",
+        )
+
     async def asyncTearDown(self) -> None:
         """Clean up after unittests"""
         await super().asyncTearDown()
EOF_114329324912

# Run only the target test file
python3 -m pytest --no-header -rA --tb=no -p no:cacheprovider tests/memory_test.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: restore original test file
git checkout 8faa353e579591f99f3322a1aab3f35f2abafdf8 "tests/memory_test.py"
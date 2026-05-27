#!/bin/bash
set -uxo pipefail

cd /testbed

# Restore the test file to the target commit state before applying patch
git checkout 28cfb99a21902d330dab6cb3762a739198cf972f "tests/plan_test.py"

# Apply the test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/plan_test.py b/tests/plan_test.py
--- a/tests/plan_test.py
+++ b/tests/plan_test.py
@@ -782,3 +782,42 @@ async def hook(_nb: PlanNotebook, _p: Plan | None) -> None:
         notebook.remove_plan_change_hook("test")
         with self.assertRaises(ValueError):
             notebook.remove_plan_change_hook("bad_hook")
+
+    async def test_recover_historical_plan_triggers_hook(self) -> None:
+        """Test recovering a historical plan triggers plan change hooks."""
+        notebook = PlanNotebook()
+        hook_calls: list[str | None] = []
+
+        def hook(_nb: PlanNotebook, plan: Plan | None) -> None:
+            hook_calls.append(plan.name if plan else None)
+
+        notebook.register_plan_change_hook("recover_hook", hook)
+
+        await notebook.create_plan(
+            "P1",
+            "desc",
+            "outcome",
+            [SubTask(name="t1", description="d", expected_outcome="e")],
+        )
+        await notebook.finish_plan("done", "final")
+
+        self.assertEqual(
+            len(hook_calls),
+            2,
+        )
+        self.assertEqual(
+            hook_calls,
+            ["P1", None],
+        )
+
+        historical_plan = (await notebook.storage.get_plans())[0]
+        await notebook.recover_historical_plan(historical_plan.id)
+
+        self.assertEqual(
+            len(hook_calls),
+            3,
+        )
+        self.assertEqual(
+            hook_calls[-1],
+            "P1",
+        )
EOF_114329324912

# Activate the python virtual environment
source /testbed/testbed/bin/activate

# Run pytest on the specified test file only,
# showing concise pass/fail/skip status with test file names
pytest --tb=short -q -rA tests/plan_test.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Restore possible changes to the test file after test run
git checkout 28cfb99a21902d330dab6cb3762a739198cf972f "tests/plan_test.py"
#!/bin/bash
set -uxo pipefail

# Activate conda environment
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed

cd /testbed

# Checkout target test file at specific commit
git checkout 28cfb99a21902d330dab6cb3762a739198cf972f "tests/plan_test.py"

# Apply test patch
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

# Run target test file
pytest --no-header -rA --tb=short -p no:cacheprovider tests/plan_test.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file
git checkout 28cfb99a21902d330dab6cb3762a739198cf972f "tests/plan_test.py"
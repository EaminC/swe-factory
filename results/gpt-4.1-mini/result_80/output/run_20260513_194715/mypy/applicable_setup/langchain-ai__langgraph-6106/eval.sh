#!/bin/bash
set -uxo pipefail

cd /testbed/libs/langgraph
git checkout 6fc5b3aeda2aaa89277c79dc3682e7c723e2abb6 "tests/test_runnable.py"

# Apply test patch to update target tests
git apply -v - <<'EOF_114329324912'
diff --git a/libs/langgraph/tests/test_runnable.py b/libs/langgraph/tests/test_runnable.py
--- a/libs/langgraph/tests/test_runnable.py
+++ b/libs/langgraph/tests/test_runnable.py
@@ -394,3 +394,21 @@ def func_untyped(x: Any, config) -> list[str]:
     assert RunnableCallable(func_untyped).invoke(
         "test", config={"tags": ["test"], "configurable": {}}
     ) == ["test"]
+
+
+def test_config_ensured() -> None:
+    def func(input: str, config: RunnableConfig) -> None:
+        assert input == "test"
+        assert config is not None
+        assert config.get("configurable") is not None
+
+    RunnableCallable(func).invoke("test")
+
+
+async def test_config_ensured_async() -> None:
+    async def func(input: str, config: RunnableConfig) -> None:
+        assert input == "test"
+        assert config is not None
+        assert config.get("configurable") is not None
+
+    await RunnableCallable(func).ainvoke("test")
EOF_114329324912

# Run pytest inside the hatch environment properly with all pytest options
hatch run pytest --full-trace --strict-markers --strict-config --durations=5 --snapshot-warn-unused tests/test_runnable.py

rc=$? # capture exit code of tests

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to clean any patch application
git checkout 6fc5b3aeda2aaa89277c79dc3682e7c723e2abb6 "tests/test_runnable.py"
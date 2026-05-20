#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset target test file to commit state before patching
git checkout 6fc5b3aeda2aaa89277c79dc3682e7c723e2abb6 "libs/langgraph/tests/test_runnable.py"

# Apply test patch
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

# Confirm the test file exists before running tests
if [ ! -f "libs/langgraph/tests/test_runnable.py" ]; then
  echo "Error: Test file libs/langgraph/tests/test_runnable.py not found"
  exit 1
fi

# Run tests directly with pytest in poetry environment, avoiding 'uv' command
cd libs/langgraph
poetry run pytest -rA --tb=short tests/test_runnable.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"
#!/bin/bash
set -uxo pipefail
cd /testbed

# Activate virtual environment
source /testbed/.venv/bin/activate

# Verify Python and pytest are available
python --version
pytest --version

# Checkout the target test file to ensure clean state
git checkout 6fc5b3aeda2aaa89277c79dc3682e7c723e2abb6 "libs/langgraph/tests/test_runnable.py"

# Apply test patch if needed
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

# Reset test file after patch application
git checkout 6fc5b3aeda2aaa89277c79dc3682e7c723e2abb6 "libs/langgraph/tests/test_runnable.py"

# Run the target test file with verbose output and pytest configuration
pytest libs/langgraph/tests/test_runnable.py -v \
    --full-trace \
    --strict-markers \
    --strict-config \
    --durations=5 \
    --snapshot-warn-unused \
    -p no:cacheprovider

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"
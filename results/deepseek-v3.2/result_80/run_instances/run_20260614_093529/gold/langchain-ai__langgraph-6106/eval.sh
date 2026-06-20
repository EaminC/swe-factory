#!/bin/bash
set -uxo pipefail

# Change to the langgraph subdirectory where the target test file is located
cd /testbed/libs/langgraph

# Ensure uv is in PATH
export PATH=/root/.local/bin:$PATH

# Activate the uv environment (uv sync already created the environment)
# The environment is already set up; we just need to ensure Python uses the correct interpreter
# which is managed by uv. The uv-run command will handle this.

# Restore the original test file to ensure a clean state
git checkout 6fc5b3aeda2aaa89277c79dc3682e7c723e2abb6 "tests/test_runnable.py"

# Apply the test patch
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

# Set environment variables for test execution
export NO_DOCKER=true  # Disable Docker dependencies since Docker services may not be fully available in the container
export TEST=tests/test_runnable.py  # Target only the specific test file

# Run the target test file using the project's test command (as per Makefile)
# Use uv run to execute pytest with the correct environment and settings
# The command is based on `make test TEST=tests/test_runnable.py` which translates to:
# uv run pytest tests/test_runnable.py
# We include the pytest.ini options: --full-trace --strict-markers --strict-config --durations=5 --snapshot-warn-unused
# and ensure output is concise but includes test names and status.
uv run pytest \
    --full-trace \
    --strict-markers \
    --strict-config \
    --durations=5 \
    --snapshot-warn-unused \
    --no-header \
    -rA \
    --tb=no \
    -p no:cacheprovider \
    tests/test_runnable.py

# Capture the exit code
rc=$?

# Output the exit code for the judge
echo "OMNIGRIL_EXIT_CODE=$rc"

# Restore the original test file to clean up
git checkout 6fc5b3aeda2aaa89277c79dc3682e7c723e2abb6 "tests/test_runnable.py"
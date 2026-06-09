#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset the target test file to the specified commit to ensure a clean state
git checkout 5780c3147afd2db9be5cd7eb88450a0f04f12977 "tests/tools/test_base_tool.py"

# Apply test patch (placeholder content to be replaced)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the virtual environment
source /testbed/testbed-venv/bin/activate

# Run only the specified test file using uv run pytest with verbose and short tracebacks,
# disable warnings for concise output
uv run pytest -rA --tb=short --disable-warnings tests/tools/test_base_tool.py

rc=$?  # Capture the exit code immediately after test run

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to the original commit state after testing (clean up)
git checkout 5780c3147afd2db9be5cd7eb88450a0f04f12977 "tests/tools/test_base_tool.py"
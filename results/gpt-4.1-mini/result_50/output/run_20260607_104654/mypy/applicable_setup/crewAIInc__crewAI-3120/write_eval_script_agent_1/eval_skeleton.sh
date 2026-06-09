#!/bin/bash
set -uxo pipefail
cd /testbed

# Reset target test file(s) to committed state before applying patch
git checkout eec1262d4fb9dc3ad700d18585a36ae30c860562 tests/test_lite_agent.py

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Reset test files again before test execution to ensure clean state
git checkout eec1262d4fb9dc3ad700d18585a36ae30c860562 tests/test_lite_agent.py

# Activate virtual environment and run only the target test file
source /testbed/.venv/bin/activate
uv run pytest -rA --tb=short --disable-warnings tests/test_lite_agent.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file after test run to clean up any patch effects
git checkout eec1262d4fb9dc3ad700d18585a36ae30c860562 tests/test_lite_agent.py
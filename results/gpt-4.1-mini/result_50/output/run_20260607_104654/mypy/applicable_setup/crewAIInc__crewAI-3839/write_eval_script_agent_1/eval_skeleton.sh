#!/bin/bash
set -uxo pipefail
cd /testbed

# Reset the target test file to the committed state before applying patch
git checkout 7e6171d5bc35da485e119fef9442faa02fcd0984 "lib/crewai/tests/test_flow.py"

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the virtual environment and run the specified test file using uv run pytest
source /testbed/.venv/bin/activate
uv run pytest -rA --tb=short --disable-warnings lib/crewai/tests/test_flow.py
rc=$?

# Echo exit code for evaluation
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file to committed state after test run
git checkout 7e6171d5bc35da485e119fef9442faa02fcd0984 "lib/crewai/tests/test_flow.py"
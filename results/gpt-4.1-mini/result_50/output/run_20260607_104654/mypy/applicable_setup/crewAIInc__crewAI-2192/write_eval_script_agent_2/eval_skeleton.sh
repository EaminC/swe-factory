#!/bin/bash
set -uxo pipefail
cd /testbed

# Reset the test file to the committed state before applying patch
git checkout b4e2db03069fcedbf80eb2130aa91d0cb68b3a43 tests/llm_test.py

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the correct virtual environment and run the specified test file using uv run pytest
source /testbed/.venv/bin/activate
uv run pytest -rA --tb=short --disable-warnings tests/llm_test.py
rc=$?

# Echo exit code for evaluation
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file to committed state after test run
git checkout b4e2db03069fcedbf80eb2130aa91d0cb68b3a43 tests/llm_test.py
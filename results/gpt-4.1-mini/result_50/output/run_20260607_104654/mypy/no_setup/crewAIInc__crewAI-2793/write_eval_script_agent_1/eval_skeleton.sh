#!/bin/bash
set -uxo pipefail
cd /testbed

# Reset the test file to the committed state before applying patch
git checkout fed397f74590a3f1c3be3bfca96e4967fe38a3e1 tests/crew_test.py

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the virtual environment and run the specified test file using uv run pytest,
# showing test file name and concise status output, disabling warnings
source /testbed/.venv/bin/activate
uv run pytest -rA --tb=short --disable-warnings tests/crew_test.py
rc=$?

# Echo exit code for evaluation
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file to committed state after test run
git checkout fed397f74590a3f1c3be3bfca96e4967fe38a3e1 tests/crew_test.py
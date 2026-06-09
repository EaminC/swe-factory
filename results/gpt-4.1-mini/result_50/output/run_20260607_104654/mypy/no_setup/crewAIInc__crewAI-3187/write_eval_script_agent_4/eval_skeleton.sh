#!/bin/bash
set -uxo pipefail
cd /testbed

# Reset the test file to the committed state before applying patch
git checkout 2ab79a7dd5623fe3adde03469afb61caefed528b tests/storage/test_mem0_storage.py

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the correct virtual environment
source /testbed/.venv/bin/activate

# Run the specified test file using pytest directly to ensure Python 3.11 venv interpreter is used
pytest -rA --tb=short --disable-warnings tests/storage/test_mem0_storage.py
rc=$?

# Echo exit code for evaluation
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file to committed state after test run
git checkout 2ab79a7dd5623fe3adde03469afb61caefed528b tests/storage/test_mem0_storage.py
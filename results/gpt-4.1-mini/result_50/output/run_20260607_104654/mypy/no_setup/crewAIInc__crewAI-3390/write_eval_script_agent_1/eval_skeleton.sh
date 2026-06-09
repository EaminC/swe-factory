#!/bin/bash
set -uxo pipefail
cd /testbed

# Reset the target test file to the committed state before applying patch
git checkout 45d0c9912c4ddb04fbd7ee515d63dde6c3e8b2cb tests/storage/test_mem0_storage.py

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the virtual environment and run the specified test file using uv run pytest
source /testbed/.venv/bin/activate
uv run pytest -rA --tb=short --disable-warnings tests/storage/test_mem0_storage.py
rc=$?

# Echo exit code for evaluation
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file to committed state after test run
git checkout 45d0c9912c4ddb04fbd7ee515d63dde6c3e8b2cb tests/storage/test_mem0_storage.py
#!/bin/bash
set -uxo pipefail
cd /testbed

# Reset target test file(s) to committed state before applying patch
git checkout 2ab79a7dd5623fe3adde03469afb61caefed528b tests/storage/test_mem0_storage.py

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Reset test files again before test execution to ensure clean state
git checkout 2ab79a7dd5623fe3adde03469afb61caefed528b tests/storage/test_mem0_storage.py

# Activate virtual environment and run only the target test file with uv run pytest to ensure correct env and python version
source /testbed/.venv/bin/activate
uv run pytest -rA --tb=short --disable-warnings tests/storage/test_mem0_storage.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file after test run to clean up any patch effects
git checkout 2ab79a7dd5623fe3adde03469afb61caefed528b tests/storage/test_mem0_storage.py
#!/bin/bash
set -uxo pipefail
cd /testbed

# Reset target test file to committed state before patching
git checkout 40a441f30eebce88b928db875e4309b892a9ac11 "tests/storage/test_mem0_storage.py"

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate virtual environment and run the specified test file only with uv run pytest
source /testbed/.venv/bin/activate
uv run pytest -rA --tb=short --disable-warnings tests/storage/test_mem0_storage.py
rc=$?

# Output exit code for evaluation
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to committed state after running tests
git checkout 40a441f30eebce88b928db875e4309b892a9ac11 "tests/storage/test_mem0_storage.py"
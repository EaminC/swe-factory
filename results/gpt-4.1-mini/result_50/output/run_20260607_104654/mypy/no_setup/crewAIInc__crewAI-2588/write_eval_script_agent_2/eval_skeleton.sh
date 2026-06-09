#!/bin/bash
set -uxo pipefail
cd /testbed

# Reset the target test file to the committed state before applying patch
git checkout 40a441f30eebce88b928db875e4309b892a9ac11 "tests/storage/test_mem0_storage.py"

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the virtual environment and install optional mem0 dependency
source /testbed/.venv/bin/activate
pip install mem0ai>=0.1.29

# Run the specified test file using uv run pytest
uv run pytest -rA --tb=short --disable-warnings tests/storage/test_mem0_storage.py
rc=$?

# Echo exit code for evaluation
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file to committed state after test run
git checkout 40a441f30eebce88b928db875e4309b892a9ac11 "tests/storage/test_mem0_storage.py"
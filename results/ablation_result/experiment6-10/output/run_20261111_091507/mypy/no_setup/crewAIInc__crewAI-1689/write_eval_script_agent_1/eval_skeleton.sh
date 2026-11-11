#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 4bc23affe0e322f4c48be7ea4e5abb0e273569d6

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the uv venv environment
source $(uv venv path testbed)/bin/activate

# Run only the specified test file with detailed output
uv run pytest -v tests/test_result_as_answer.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset repository changes on the test file to clean up
git checkout 4bc23affe0e322f4c48be7ea4e5abb0e273569d6 tests/test_result_as_answer.py
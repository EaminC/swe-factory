#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout cf9762d3abd3cad227bbd859a3ef4f95dff164a3

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate virtual environment for test execution
source /testbed/.venv/bin/activate

# Ensure pytest is installed
pip install pytest

# Run only the specified test file using unittest module as per GitHub workflow recommendation
python -m unittest tests.utils.test_memory_mem0
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout cf9762d3abd3cad227bbd859a3ef4f95dff164a3 tests/utils/test_memory_mem0.py
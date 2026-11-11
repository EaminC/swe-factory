#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 4bc23affe0e322f4c48be7ea4e5abb0e273569d6

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the python virtual environment
source /testbed/.venv/bin/activate

# Ensure pytest and related test dependencies are installed
pip install pytest pytest-vcr pytest-asyncio pytest-subprocess

# Run tests on the specified test file only
pytest -v tests/test_result_as_answer.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Since tests/test_result_as_answer.py does not exist at this commit or is untracked,
# skip attempting to reset it to avoid git errors.
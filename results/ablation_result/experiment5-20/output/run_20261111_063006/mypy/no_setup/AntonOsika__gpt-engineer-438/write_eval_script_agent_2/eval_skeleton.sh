#!/bin/bash
set -uxo pipefail

cd /testbed

git checkout 2b8e056d5d4d14665b88a01c41356253c94b9259 

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

git checkout 2b8e056d5d4d14665b88a01c41356253c94b9259 tests/test_token_usage_log.py

# Export OPENAI_API_KEY from environment or fail if unset
if [ -z "${OPENAI_API_KEY}" ]; then
    echo "ERROR: OPENAI_API_KEY is not set. Please set the environment variable before running tests."
    exit 1
fi

source /testbed/testbed/bin/activate

# Run only the specified test file with pytest showing test names and statuses concisely
pytest --no-header -rA --tb=short tests/test_token_usage_log.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the patched test file to clean state after test run
git checkout 2b8e056d5d4d14665b88a01c41356253c94b9259 tests/test_token_usage_log.py